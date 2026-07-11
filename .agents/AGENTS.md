
## GovAssist Deployment & Release Workflow

When working on backend features or refinements for GovAssist, ALWAYS follow this strict deployment pipeline:

1. **Local Development (Dev Stage)**:
   - Perform all backend edits (PHP/HTML/JS/CSS) EXCLUSIVELY inside the active Laragon directory: C:\laragon\www\govassist_backend.
   - Use the local Laragon MySQL database (`localhost`) for testing. **Never** use the online Awardspace database credentials (e.g., `fdb1032.awardspace.net`) in the local `db.php`.
   - For the Flutter frontend, ensure the `baseUrl` in `lib/data/service_data.dart` points to the local backend (`http://localhost/govassist_backend/api` or `http://10.0.2.2/govassist_backend/api`) during development, not the live server URL.
   - Do NOT edit the govassist_backend copies located on the Desktop or inside the Flutter workspace during active development.

2. **The Flattening Process (Build Stage)**:
   - Once a feature is fully tested locally, run the deployment pipeline script (C:\Users\Mark Jed M Cagatin\Desktop\govassist\release_pipeline.ps1).
   - This script automatically flattens govassist_backend into C:\laragon\www\govassist_flat, updates all ../api/ and ../ paths, and prepares it for Awardspace upload.

3. **Updating the Release Directory (Release Stage)**:
   - The deployment script will automatically synchronize the flattened, finalized code into C:\Users\Mark Jed M Cagatin\Desktop\govassist_release\govassist_backend.
   - This directory acts as the production-ready snapshot. Instruct the user to upload these files to Awardspace.

4. **Review and Version Control**:
   - After any changes, review all edits and analyze if the connections and system status are aligned and functioning correctly.
   - Once verified, automatically commit all changes and push them to the repository.
   - Trigger the necessary actions (such as the release pipeline) to update the deployed version.
