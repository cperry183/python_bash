Steps:

Log in to Harbor: Access your Harbor web interface with an administrative account.
Navigate to Robot Accounts: Go to "Administration" -> "Robot Accounts."
Create a New Robot Account:
Click "New Robot Account."
Give it a meaningful name (e.g., "vulnerability-scanner").
Set the "Access Level" to "Project Admin" or similar, depending on the minimum required permissions. The robot account needs permissions to read projects, repos, tags, vulnerability scans, and possibly lock tags.
Ensure the Robot account has read access to all projects you want to scan. If you want to limit it, you can select specific projects.
Click "Add."
Important: Copy the "Token" (password) shown after creation. This is the only time you'll see it.
Use the Robot Account:
In your Python script, use the robot account's name as the --admin argument and the copied "Token" as the --password argument.
