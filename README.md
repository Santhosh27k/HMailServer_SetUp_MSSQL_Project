# 📘 hMailServer SQL Project

**Author:** Santhosh  S
**GitHub:** [https://github.com/Santhosh27k](https://github.com/Santhosh27k)  
**LinkedIn:** [https://www.linkedin.com/in/santhosh-s-219287228](https://www.linkedin.com/in/santhosh-s-219287228)

---

## 🧩 Description
A complete SQL setup and configuration guide for **hMailServer** using **Microsoft SQL Server (MSSQL)** as an external database.  
Includes scripts to create, manage, and remove databases, logins, roles, and tables — along with a step-by-step installation and connection guide for hMailServer.

---

## 🗂️ Folder Contents
| File Name | Purpose |
|------------|----------|
| 1_Main_Script_Prerequisites.sql | Drops existing hMailServer DB, tables, and constraints (cleanup) |
| 2_Main_find_and_delete_that_SQL_login.sql | Deletes existing SQL logins linked to old hMailServer setups |
| 3_Main_Create_Login_Database.sql | Creates new SQL login, password, and database |
| 4_Main_Create_Table.sql | Creates tables, indexes, and constraints |
| 5_Alter_Role_Sysadmin.sql | Alters or grants admin-level permissions |
| 6_Change_Password.sql | Changes SQL user password |
| 7_Alter_Name_on_different_levels.sql | Renames users or remaps logins |
| 1.Step_By_Step_Guide_Database_setup(Readme).txt | SQL setup instructions |
| H_MailServer_Overall_Step-by-Step_Readme.pdf | Full hMailServer + MSSQL installation guide |

---

## ⚙️ Usage
1. Run the SQL scripts in the listed order.  
2. Follow the setup instructions in the README guide.  
3. Complete the external database configuration in hMailServer setup.  
4. Connect via **hMailServer Administrator** using the admin password you created.

---

## 🧠 Notes
- Steps 1 and 2 are optional (use only for cleanup).  
- Use Microsoft SQL Server (MSSQL).  
- Back up existing databases before running cleanup scripts.  
- `.gitignore` is included to protect sensitive files and credentials.

---

**✅ Project Created and Maintained by [Santhosh](https://github.com/Santhosh27k)**  
For professional or educational reference only.
