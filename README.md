## 🚀 **Gaia Multi-Node Setup & CUDA Installation Script**  

This script automates the setup and installation of essential dependencies, updates the system, and configures **CUDA Toolkit 12.8** for running Gaia nodes efficiently.  

---

### **📌 Features**
✅ **System Update & Upgrade** – Ensures the latest system packages are installed.  
✅ **Essential Tools Installation** – Installs `curl`, `htop`, `git`, `nvtop`, `jq`, and more.  
✅ **CUDA Toolkit 12.8 Installation** – Enables NVIDIA GPU acceleration.  
✅ **Google Chrome GPG Fix** – Prevents common update issues.  
✅ **Fully Automated Setup** – Just run the command below and relax!  

---

### **🛠️ Installation & Usage**
Run the following command in your terminal (**as root or with `sudo`**):  

```bash
apt update && apt install -y curl && rm -rf ~/mltnodes.sh; \
curl -O https://raw.githubusercontent.com/Jayanth2407/gaia_testing/main/mltnodes.sh && \
chmod +x mltnodes.sh && ./mltnodes.sh
```

---

### **🌀 Workflow Summary**
1️⃣ **Update System & Install `curl`** (ensures `curl` is available).  
2️⃣ **Download `mltnodes.sh` from GitHub** (latest version from your repo).  
3️⃣ **Give Execution Permission** (`chmod +x mltnodes.sh`).  
4️⃣ **Run the Script** (`./mltnodes.sh` to start installation).  
5️⃣ **Check & Fix Google Chrome’s GPG Key** (prevents update errors).  
6️⃣ **Update Package Lists** (`apt update`).  
7️⃣ **Upgrade System Packages** (`apt upgrade -y`).  
8️⃣ **Install Essential Tools** (`nvtop`, `git`, `jq`, etc.).  
9️⃣ **Install CUDA Toolkit 12.8** (for NVIDIA GPU acceleration).  
🔟 **Final Confirmation** – Ensures all dependencies are installed.  

---

### **🔗 Repository**
📂 **GitHub Repository:** [Jayanth2407/gaia_testing](https://github.com/Jayanth2407/gaia_testing)  

---

### **📌 Notes**
- Ensure **you have root access** (`sudo` required).  
- For GPU support, **NVIDIA drivers must be installed** before running CUDA.  
- To verify CUDA installation, run:  
  ```bash
  nvidia-smi
  nvcc --version
  ```

---

💡 **Now, just copy-paste the install command, sit back, and let the script do the work! 🚀🔥**
