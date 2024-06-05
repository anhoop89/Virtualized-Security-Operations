# Final Project: DevOps - Advanced Service Implementation

## Introduction
- Engineered a virtualized network environment using FreeBSD as the base host and Ubuntu as a primary VM, enhancing system robustness and scalability.
- Implemented comprehensive network services including TCP/IP, DHCP, DNS, and VPN on the Ubuntu VM for secure and efficient remote connectivity.
- Deployed and configured containerized applications such as GitLab, Bitwarden, and ZoneMinder to improve system management and security.
- Created a CI/CD pipeline using Jekyll for generating static sites from GitLab repos, showcasing advanced DevOps capabilities.
## Tasks

### CS410/510 Tasks:
1. **GitLab Instance:**
   - Install a GitLab instance on your Ubuntu system.
   - Ensure it is fully containerized and added to your `docker-compose.yml` file.
   - Document the installation and configuration in your `final.md` file.

2. **Bitwarden Instance:**
   - Install a dockerized, self-hosted Bitwarden instance.
   - Ensure configuration files are stored on a mapped volume.
   - Document the installation and configuration in your `final.md` file.

3. **ZoneMinder:**
   - Install a containerized ZoneMinder for security camera monitoring.
   - Configure it to use a mapped volume for storage.
   - Document the installation and configuration in your `final.md` file.

### CS510 Additional Task:
4. **Static Site Generator:**
   - Research how GitHub generates static pages for GitHub Pages.
   - Create a similar setup with the GitLab instance you configured.
   - Implement a static site generator (e.g., Jekyll) and set up a CI/CD pipeline to generate a static site from a GitLab repo.
   - Ensure it is fully containerized and added to your `docker-compose.yml` file.
   - Document the installation and configuration in your `final.md` file.
   - Document any additional firewall rules added to your bastion host.

## Submission
Once completed, your repository should include a folder named `final` containing `final.md` with all the requested information. Commit and push this folder along with any necessary screenshots to your GitLab repository to complete the submission.

