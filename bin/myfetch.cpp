#include <fmt/core.h>
#include <fmt/color.h>
#include <unistd.h>
#include <sys/utsname.h>
#include <fstream>
#include <string>
#include <vector>
#include <sys/sysinfo.h>
#include <sstream>
std::string get_os_pretty_name() {
    std::ifstream file("/etc/os-release");
    std::string line;
    while (std::getline(file, line)) {
        if (line.rfind("PRETTY_NAME=", 0) == 0) {
            // Extract value after "=" and remove quotes
            return line.substr(13, line.size() - 14);
        }
    }
    return "Unknown";
}



std::string get_kernel_version() {
    struct utsname buffer;
    if (uname(&buffer) != 0) {
        return "Unknown";
    }
    return buffer.release;
}

std::string get_memory_usage() {
    std::ifstream meminfo("/proc/meminfo");
    if (!meminfo) {
        return "Unknown";
    }

    std::string line;
    long total, free, buffers, cached;

    while (std::getline(meminfo, line)) {
        std::istringstream iss(line);
        std::string key;
        long value;
        iss >> key >> value;
        if (key == "MemTotal:") {
            total = value;
        } else if (key == "MemFree:") {
            free = value;
        } else if (key == "Buffers:") {
            buffers = value;
        } else if (key == "Cached:") {
            cached = value;
        }
    }
    // convert to GiB


    long used = total - free - buffers - cached;
    total /= 1024 * 1024;
    used /= 1024 * 1024;
    return fmt::format("Used: {} GiB / Total: {} GiB", used, total);
}

std::string get_uptime() {
    struct sysinfo info;
    if (sysinfo(&info) != 0) {
        return "Unknown";
    }
    int hours = info.uptime / 3600;
    int mins = (info.uptime % 3600) / 60;
    return fmt::format("{} hours, {} mins", hours, mins);
}

// Add more functions to get other information like memory, uptime, package count, etc.

int main() {

    const char* ascii_art = R"(
                                 .;o,
        __."iIoi,._              ;pI __-"-xx.,_
      `.3"P3PPPoie-,.            .d' `;.     `p;
     `O"dP"````""`PdEe._       .;'   .     `  `|   NACK
    "$#"'            ``"P4rdddsP'  .F.    ` `` ;  /
   i/"""     *"Sp.               .dPff.  _.,;Gw'
   ;l"'     "  `dp..            "sWf;fe|'
  `l;          .rPi .    . "" "dW;;doe;
   $          .;PE`'       " "sW;.d.d;
   $$        .$"`     `"saed;lW;.d.d.i
   .$M       ;              ``  ' ld;.p.
__ _`$o,.-__  "ei-Mu~,.__ ___ `_-dee3'o-ii~m. ____
    )";
    //std::string username = 'chronos'
    fmt::print("{}", ascii_art);
    char hostnameBuffer[256]; // Adjust the size as needed
    if (gethostname(hostnameBuffer, sizeof(hostnameBuffer)) == -1) {
        perror("gethostname");
        return 1;
    }
    fmt::print("\n");
    std::string hostname(hostnameBuffer);  // Declare and initialize 'hostname'

    // Now 'hostname' is in scope for the fmt::print statement
    
    std::string os = get_os_pretty_name();
    std::string kernel = get_kernel_version();
    auto custom_color = fmt::rgb(190, 80, 70); // Magenta color as an example
    // Format and print other information
    // Printing hostname in bold and custom color
    // Print hostname in bold
    fmt::print(fmt::emphasis::bold, "{}\n", hostname);

    // Print icon in custom color and OS in default color
    fmt::print(fg(custom_color), " 󰣇 ");
    fmt::print(" {}\n", os);

    // Print icon in custom color and Kernel in default color
    fmt::print(fg(custom_color), "  ");
    fmt::print(" {}\n", kernel);

    // Print icon in custom color and Memory in default color
    fmt::print(fg(custom_color), " 󰍛 ");
    fmt::print(" Memory: {}\n", get_memory_usage());

    // Print icon in custom color and Uptime in default color
    fmt::print(fg(custom_color), " 󰥔 ");
    fmt::print(" Uptime: {}\n", get_uptime());

    return 0;
}
