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


if __name__ == "__main__":
    unittest.main()
