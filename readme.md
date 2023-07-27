# Depend
make sure conan is ok, if not, install like this:
- pip install conan 
- conan remote add cowasoft http://172.16.112.5:8081/artifactory/api/conan/cowasoft
- conan config set general.revisions_enabled=1
- conan user -p Lverify1  -r cowasoft admin

# Build
for first build
-  git submodule init
-  git submodule update --recursive --remote
-  mkdir build && cd build
-  conan install ..

for non-first build
- cd build
- cmake -DCMAKE_BUILD_TYPE=Debug ..  
- clear && make -j4

# Run
- ./bin/sim_new_client