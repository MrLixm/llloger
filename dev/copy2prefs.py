"""
Copy the llloger module to the LUA_PATH directory registered by Katana for testing.

Python 3+
"""
import subprocess
from pathlib import Path


CONFIG = {
    "source": Path("../lllogger.lua").resolve(),
    "target": Path(r"Z:\dccs\katana\library\shelf0006\lua"),
}


def run():

    src_path = CONFIG.get("source")
    target_path = CONFIG.get("target")

    # build command line arguments
    args = [
        'robocopy',
        str(src_path.parent),
        str(target_path),
        # copy option
        str(src_path.name),
        # logging options
        "/nfl",  # no file names are not to be logged.
        "/ndl",  # no directory names logged.
        "/np",  # no progress of the copying operation
        "/njh",  # no job header.
        # "/njs",  # no job summary.
    ]
    print(f"[{__name__}][run] copying src to target ...")
    subprocess.call(args)

    print(
        f"[{__name__}][run] Finished. Copied :\n"
        f"    <{src_path}> to\n"
        f"    <{target_path}>"
    )
    return


if __name__ == '__main__':

    run()
