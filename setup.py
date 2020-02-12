
from distutils.core import setup
from git import Repo

repo = Repo()

# Get version before adding version file
ver = repo.git.describe('--tags')

# append version constant to package init
with open('python/AtlasRd53/__init__.py','a') as vf:
    vf.write(f'\n__version__="{ver}"\n')

setup (
   name='atlas_rd53_fw_lib',
   version=ver,
   packages=['AtlasRd53', ],
   package_dir={'':'python'},
)
