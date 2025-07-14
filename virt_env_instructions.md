# 1. Navigate to your project directory (replace with your actual path)
cd /path/to/your/project

# 2. Create the virtual environment
python3 -m venv .venv

# 3. Activate the virtual environment
# On Linux/macOS:
source .venv/bin/activate
# On Windows (Command Prompt):
# .venv\Scripts\activate.bat
# On Windows (PowerShell):
# .venv\Scripts\Activate.ps1

# 4. Install Jupyter and ipykernel (and your project libraries)
pip install notebook ipykernel
pip install neo4j pandas numpy matplotlib # Example libraries, add what you need

# 5. Register the virtual environment as a Jupyter Kernel
python -m ipykernel install --user --name=MyNeo4jProjectEnv --display-name "Python 3 (Neo4j Project)"

# 6. Launch Jupyter Notebook (ensure virtual environment is active)
jupyter lab

# 7. Deactivate the virtual environment (when done working)
deactivate
