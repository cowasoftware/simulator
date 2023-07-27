#add environment $QT5152DIR qtdir
mkdir build
cd build
conan install ..
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j
cd bin
touch qt.conf
echo -e "[Paths]" >> ./qt.conf
echo -e "Prefix = ../" >> ./qt.conf
echo -e "Plugins = plugins" >> ./qt.conf
echo -e "Imports = qml" >> ./qt.conf
echo -e "Qml2Imports = qml" >> ./qt.conf
echo -e "Libraries = lib" >> ./qt.conf
linuxdeployqt sim_new_client -no-strip
cd ..
cp -rf $QT5152DIR/5.15.2/gcc_64/qml ./
cp $QT5152DIR/5.15.2/gcc_64/lib/libQt5QmlWorkerScript.so.5.15.2 ./lib/
cp $QT5152DIR/5.15.2/gcc_64/lib/libQt5QuickControls2.so.5.15.2 ./lib/
cp $QT5152DIR/5.15.2/gcc_64/lib/libQt5QuickTemplates2.so.5.15.2 ./lib/
mv ./lib/libQt5QmlWorkerScript.so.5.15.2 ./lib/libQt5QmlWorkerScript.so.5
mv ./lib/libQt5QuickControls2.so.5.15.2 ./lib/libQt5QuickControls2.so.5
mv ./lib/libQt5QuickTemplates2.so.5.15.2 ./lib/libQt5QuickTemplates2.so.5
rm ./lib/libQt53D*
rm ./lib/libQt5Bluetooth.so.5
rm ./lib/libQt5Bodymovin.so.5
rm ./lib/libQt5Charts.so.5
rm ./lib/libQt5Concurrent.so.5
rm ./lib/libQt5DataVisualization.so.5
rm ./lib/libQt5Gamepad.so.5
rm ./lib/libQt5Location.so.5
rm ./lib/libQt5MultimediaQuick.so.5
rm ./lib/libQt5Multimedia.so.5
rm ./lib/libQt5Nfc.so.5
rm ./lib/libQt5PositioningQuick.so.5
rm ./lib/libQt5Positioning.so.5
rm ./lib/libQt5Purchasing.so.5
rm ./lib/libQt5Quick3D*
rm ./lib/libQt5QuickParticles.so.5
rm ./lib/libQt5QuickShapes.so.5
rm ./lib/libQt5QuickTest.so.5
rm ./lib/libQt5RemoteObjects.so.5
rm ./lib/libQt5Scxml.so.5
rm ./lib/libQt5Sensors.so.5
rm ./lib/libQt5Sql.so.5
rm ./lib/libQt5Test.so.5
rm ./lib/libQt5Wayland*
rm ./lib/libQt5WebChannel.so.5
rm ./lib/libQt5WebEngineCore.so.5
rm ./lib/libQt5WebEngine.so.5
rm ./lib/libQt5WebSockets.so.5
rm ./lib/libQt5WebView.so.5
rm ./lib/libQt5XmlPatterns.so.5
touch ./run.sh
echo 'PWD=`pwd`' >> ./run.sh
echo 'export LD_LIBRARY_PATH=${PWD}/lib:$LD_LIBRARY_PATH' >> ./run.sh
echo -e "nohup ./bin/sim_new_client &" >> ./run.sh
chmod 777 ./run.sh
mkdir sim_new_client
cp -rf ./bin ./sim_new_client
mv ./lib ./sim_new_client
mv ./plugins ./sim_new_client
mv ./qml ./sim_new_client
mv ./translations ./sim_new_client
mv ./run.sh ./sim_new_client
rm ./bin/qt.conf
rm -rf ./libexec
rm -rf ./resources
rm ../AppRun
zip -r -o sim_new_client.zip ./sim_new_client/
rm -rf ./sim_new_client
