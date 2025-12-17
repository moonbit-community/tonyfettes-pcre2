import shutil
from pathlib import Path
import subprocess


def test(publish: Path):
    subprocess.run(["moon", "test", "--target", "native"], cwd=publish, check=True)


def main():
    publish_path = Path("publish")
    if publish_path.exists():
        shutil.rmtree(publish_path)

    publish_path.mkdir(parents=True)
    shutil.copy("moon.mod.json", publish_path / "moon.mod.json")
    shutil.copy("README.md", publish_path / "README.md")
    shutil.copy("LICENSE", publish_path / "LICENSE")
    shutil.copytree("src", publish_path / "src")
    shutil.copytree("deps", publish_path / "deps")
    (publish_path / "src" / ".gitignore").unlink()
    test(publish_path)
    for test_path in (publish_path / "src").rglob("*_test.mbt"):
        test_path.unlink()
    for mbti_path in (publish_path / "src").rglob("*.mbti"):
        mbti_path.unlink()
    subprocess.run(["moon", "publish"], cwd=publish_path)


if __name__ == "__main__":
    main()
