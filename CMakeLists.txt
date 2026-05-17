cmake_minimum_required(VERSION 3.16)

project(AlinaRE VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Multimedia)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appAlinaRE
    main.cpp
    src/SudokuGenerator.h
    src/SudokuGenerator.cpp
    src/GameModel.h
    src/GameModel.cpp
    src/LeaderboardModel.h
    src/LeaderboardModel.cpp
)

target_include_directories(appAlinaRE PRIVATE src)

qt_add_qml_module(appAlinaRE
    URI AlinaRE
    VERSION 1.0
    QML_FILES
        Main.qml
        LoadingScreen.qml
        MainMenu.qml
        GameScreen.qml
        LeaderboardScreen.qml
    RESOURCES
        resources/characters/leon.png
        resources/characters/claire.png
        resources/characters/jill.png
        resources/characters/chris.png
        resources/characters/ada.png
        resources/characters/wesker.png
        resources/characters/nemesis.png
        resources/characters/tyrant.png
        resources/characters/ethan.png
    # Audio — uncomment each line after adding the file to resources/audio/
    #     resources/audio/ambient.mp3
    #     resources/audio/place.wav
    #     resources/audio/error.wav
    #     resources/audio/hint.wav
    #     resources/audio/undo.wav
    #     resources/audio/win.wav
    #     resources/audio/lose.wav
    #     resources/audio/select.wav
)

set_target_properties(appAlinaRE PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appAlinaRE
    PRIVATE Qt6::Quick Qt6::Multimedia
)

install(TARGETS appAlinaRE
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
