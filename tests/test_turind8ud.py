import importlib.machinery
import importlib.util
from pathlib import Path
import sys
from types import ModuleType, SimpleNamespace
import unittest
from unittest.mock import patch


TOOLS = Path(__file__).resolve().parents[1] / "tools"
BOARD = "TURIND8UD-2T/X550"


def load_tool(name):
    loader = importlib.machinery.SourceFileLoader(name, str(TOOLS / name))
    spec = importlib.util.spec_from_loader(name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


class TurinChassisTest(unittest.TestCase):
    def test_vm2_and_vm8_2g_hardware_identification(self):
        identifier = load_tool("server_identifier")
        for product, chassis, hbas, alias_style in (
            ("VM2", "VM2", 0, "BYPATH"),
            ("VM8-2G", "VM8", 1, "F2STORNADO"),
        ):
            for tier in ("Base", "Enhanced", "Turbo"):
                model = f"Proxinator-{product}-{tier}"
                with self.subTest(model=model):
                    self.assertTrue(identifier._model_matches_known_hardware(
                        model, BOARD, hbas, 0, chassis,
                    ))
                    self.assertFalse(identifier._model_matches_known_hardware(
                        model, BOARD, hbas + 1, 0, chassis,
                    ))
                    candidates = identifier._candidate_models_for_hardware(
                        BOARD, hbas, 0, chassis,
                    )
                    self.assertIn(model, candidates)
                    self.assertEqual(identifier.g_product_lut[model][4], alias_style)

    def test_vm2_udev_aliases_and_dmap_agree(self):
        pyudev = ModuleType("pyudev")
        pyudev.Context = lambda: None
        pyudev.Device = object
        with patch.dict(sys.modules, {"pyudev": pyudev}):
            aliases = load_tool("id_disk_custom_alias")
        dmap = load_tool("dmap")
        expected = {"0000:40:03.3": "1-1", "0000:40:03.4": "1-2"}
        self.assertEqual(aliases.get_alias_pcieport_parents("VM2", BOARD), expected)
        for root, bay in expected.items():
            device = SimpleNamespace(ancestors=[
                SimpleNamespace(driver="nvme", sys_name="nvme0"),
                SimpleNamespace(driver="pcieport", sys_name=root),
            ])
            parent = aliases.get_pcieport_parent_sys_name(device)
            self.assertEqual(expected[parent], bay)
        with patch.object(dmap, "get_version", return_value="test"):
            mapping = dmap.create_vdev_id({
                "Alias Style": "BYPATH",
                "Chassis Size": "VM2",
                "Motherboard": {"Product Name": BOARD},
            })
        self.assertEqual(
            [line.split()[1] for line in mapping.splitlines() if line.startswith("alias ")],
            list(expected.values()),
        )
    def test_e16_turind8x_aliases_depend_on_cpu_generation(self):
        pyudev = ModuleType("pyudev")
        pyudev.Context = lambda: None
        pyudev.Device = object
        with patch.dict(sys.modules, {"pyudev": pyudev}):
            aliases = load_tool("id_disk_custom_alias")

        # Storage adapters in PCIE0/2/4/6 -> rows 1-4. Any root complex ID other than
        # the EPYC 9005 one (0x153a), e.g. EPYC 9004 (0x14a4), uses the default table.
        for device_id, row_buses in (
            ("0x14a4", {1: "40", 2: "00", 3: "c0", 4: "80"}),
            (None, {1: "40", 2: "00", 3: "c0", 4: "80"}),
            ("0x153a", {1: "20", 2: "00", 3: "e0", 4: "c0"}),
        ):
            with self.subTest(device_id=device_id), patch.object(
                aliases, "get_root_complex_device_id", return_value=device_id
            ):
                result = aliases.get_alias_pcieport_parents("E16", "TURIND8X-2T/500W")
            self.assertEqual(len(result), 16)
            for row, bus in row_buses.items():
                self.assertEqual(result[f"0000:{bus}:01.2"], f"{row}-1")
                self.assertEqual(result[f"0000:{bus}:01.3"], f"{row}-4")

        # Verified on asm-testing (EPYC 9965): every row uses .2, .1, .4, .3
        with patch.object(aliases, "get_root_complex_device_id", return_value="0x153a"):
            result = aliases.get_alias_pcieport_parents("E16", "TURIND8X-2T/500W")
        self.assertEqual(result["0000:00:01.1"], "2-2")
        self.assertEqual(result["0000:00:01.4"], "2-3")


if __name__ == "__main__":
    unittest.main()
