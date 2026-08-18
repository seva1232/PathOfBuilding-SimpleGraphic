#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

extern "C" int RunLuaFileAsWin(int argc, char** argv);

namespace {

std::filesystem::path FindBundledScript(const char* executable)
{
    std::error_code error;
    const auto executablePath = std::filesystem::weakly_canonical(executable, error);
    const auto executableDir = error ? std::filesystem::current_path() : executablePath.parent_path();
    const std::filesystem::path candidates[] = {
        executableDir / "../Resources/Launch.lua",
        executableDir / "Launch.lua",
        std::filesystem::current_path() / "Launch.lua",
    };

    for (const auto& candidate : candidates) {
        if (std::filesystem::is_regular_file(candidate, error)) {
            return std::filesystem::weakly_canonical(candidate, error);
        }
        error.clear();
    }
    return {};
}

} // namespace

int main(int argc, char** argv)
{
    std::vector<std::string> arguments;
    if (argc > 1) {
        arguments.reserve(static_cast<size_t>(argc - 1));
        for (int index = 1; index < argc; ++index) {
            arguments.emplace_back(argv[index]);
        }
    } else {
        const auto script = FindBundledScript(argv[0]);
        if (script.empty()) {
            std::cerr << "Path of Building could not find Launch.lua.\n"
                         "Pass its path explicitly:\n  "
                      << argv[0] << " /path/to/PathOfBuilding/Launch.lua\n";
            return 2;
        }
        arguments.emplace_back(script.string());
    }

    std::vector<char*> engineArguments;
    engineArguments.reserve(arguments.size());
    for (auto& argument : arguments) {
        engineArguments.push_back(argument.data());
    }
    return RunLuaFileAsWin(static_cast<int>(engineArguments.size()), engineArguments.data());
}
