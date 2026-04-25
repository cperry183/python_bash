<div align="center">
  <img src="https://img.shields.io/badge/Python-3.x-blue?style=for-the-badge&logo=python" alt="Python 3.x" />
  <img src="https://img.shields.io/badge/Bash-4.x%2B-green?style=for-the-badge&logo=gnu-bash" alt="Bash 4.x+" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License" />
</div>

<h1 align="center">🐍 Bash & Python Utility Scripts</h1>

<p align="center">
  <strong>A comprehensive collection of Bash and Python scripts designed for system administration, automation, and various utility tasks.</strong>
</p>

---

## 📖 Overview

This repository serves as a centralized collection of useful Bash and Python scripts. These scripts are developed to automate repetitive tasks, assist in system administration, provide quick utility functions, and offer practical examples for integrating Python with Bash. The collection covers a wide range of functionalities, from system health checks and log analysis to data processing and deployment utilities.

### ✨ Key Features

| Category | Description |
| :--- | :--- |
| 🐚 **Bash Utilities** | A variety of shell scripts for system monitoring, file management, network diagnostics, and automation of common administrative tasks. |
| 🐍 **Python Tools** | Python scripts for more complex data processing, API interactions, and advanced automation, often complementing Bash scripts. |
| 📊 **Data Processing** | Scripts for handling and transforming data, including CSV manipulation and conversion to other formats. |
| 🚀 **Deployment & CI/CD** | Utilities and examples related to continuous integration/continuous deployment pipelines, such as Jenkins build scripts. |
| 🛡️ **Security & Compliance** | Scripts for security-related tasks, including agent upgrades (e.g., CrowdStrike) and security analysis tools. |
| 📚 **Cheat Sheets & Examples** | Reference materials and practical examples to aid in understanding and using various commands and scripting techniques. |

---

## 📂 Repository Structure

```text
python_bash/
├── BASH/                           # General Bash utility scripts
│   ├── add_tux.sh
│   ├── agent.sh
│   ├── check_crowstrike.sh
│   ├── ...                         # Many other .sh files
├── PYTHON/                         # General Python utility scripts
│   ├── check_maintenance_teams.py
│   ├── cvs_cut.py
│   ├── ping.py
│   ├── testing_hooks.py
├── bash_scripts/                   # Additional Bash scripts (potentially specialized)
│   └── ...
├── cheat_sheets/                   # Reference materials and command cheat sheets
│   └── ...
├── crowdstrike_upgrade/            # Scripts related to CrowdStrike agent upgrades
│   ├── crowdstrike-hsm.sh
│   └── crowdstrike.sh
├── csv-md/                         # Scripts for CSV to Markdown conversion
│   └── ...
├── jenkins_build/                  # Jenkins build related scripts
│   └── ...
├── jenkins_upgrade/                # Jenkins upgrade related scripts
│   └── ...
├── pdsh_bash/                      # Scripts utilizing pdsh for parallel shell execution
│   └── ...
├── py-bash-scripts/                # Submodule or combined Python/Bash scripts
│   └── ...
├── python/                         # Another directory for Python scripts (potentially older or specific)
│   └── ...
├── security-analyst/               # Tools and scripts for security analysis
│   └── ...
├── dashboard.py                    # A Python script likely for a dashboard application (e.g., Dash)
├── requirements.txt                # Python dependencies for Python scripts
└── README.md                       # This README file
```

---

## 🚀 Getting Started

To utilize the scripts in this repository, follow these general steps.

### Prerequisites

*   **Git** for cloning the repository.
*   **Bash** environment (standard on Linux/macOS, available via WSL on Windows).
*   **Python 3.x** for running Python scripts.
*   `pip` (Python package installer) for Python dependencies.

### Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/cperry183/python_bash.git
    cd python_bash
    ```

2.  **Install Python dependencies (if needed):**

    Some Python scripts may require specific libraries. Install them using:

    ```bash
    pip install -r requirements.txt
    ```

### Usage

**For Bash Scripts:**

Navigate to the `BASH/` or `bash_scripts/` directory and execute the desired script. Ensure the script has execute permissions (`chmod +x script_name.sh`).

```bash
cd BASH/
./add_tux.sh
```

**For Python Scripts:**

Navigate to the `PYTHON/` directory or the root for `dashboard.py` and run the script using the Python interpreter.

```bash
cd PYTHON/
python check_maintenance_teams.py

# For dashboard.py (from the root of the repository)
python dashboard.py
```

Refer to individual script files for specific usage instructions, arguments, and examples.

---

## 🤝 Contributing

Contributions are welcome! If you have useful Bash or Python scripts that fit the theme of system administration, automation, or general utilities, please consider contributing. To do so:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/your-script-name`).
3.  Add your script(s) to the appropriate directory (e.g., `BASH/`, `PYTHON/`).
4.  Ensure your script is well-commented and includes a clear header explaining its purpose, usage, and any dependencies.
5.  Commit your changes (`git commit -m 'Add new script: your_script_name'`).
6.  Push to the branch (`git push origin feature/your-script-name`).
7.  Open a Pull Request with a clear description of your contribution.

---

## 📜 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.
