cmake_minimum_required(VERSION 3.22)
# Windows: static MSVC runtime so the plugin runs without installing the VC++ redistributable.
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
project(DrumTrigger VERSION 1.0.0)

include(FetchContent)
FetchContent_Declare(JUCE
    GIT_REPOSITORY https://github.com/juce-framework/JUCE.git
    GIT_TAG 8.0.4)
FetchContent_MakeAvailable(JUCE)

if(APPLE)
    set(DT_FORMATS VST3 AU Standalone)
else()
    set(DT_FORMATS VST3 Standalone)
endif()

juce_add_plugin(DrumTrigger
    COMPANY_NAME "YourCompany"
    PLUGIN_MANUFACTURER_CODE Ydct
    PLUGIN_CODE Dtrg
    FORMATS ${DT_FORMATS}
    PRODUCT_NAME "Drum Trigger"
    IS_SYNTH FALSE
    NEEDS_MIDI_INPUT FALSE
    NEEDS_MIDI_OUTPUT TRUE
    IS_MIDI_EFFECT FALSE
    COPY_PLUGIN_AFTER_BUILD TRUE)

target_sources(DrumTrigger PRIVATE
    Source/PluginProcessor.cpp
    Source/PluginEditor.cpp)

target_compile_features(DrumTrigger PRIVATE cxx_std_17)

target_compile_definitions(DrumTrigger PUBLIC
    JUCE_WEB_BROWSER=0
    JUCE_USE_CURL=0
    JUCE_VST3_CAN_REPLACE_VST2=0
    JUCE_PLUGINHOST_VST3=1
    JUCE_PLUGINHOST_AU=$<IF:$<BOOL:${APPLE}>,1,0>)

target_link_libraries(DrumTrigger PRIVATE
    juce::juce_audio_utils
    juce::juce_audio_processors
    juce::juce_dsp
    PUBLIC
    juce::juce_recommended_config_flags
    juce::juce_recommended_warning_flags)

if(MSVC)
    target_compile_options(DrumTrigger PRIVATE /MP /bigobj)
endif()
