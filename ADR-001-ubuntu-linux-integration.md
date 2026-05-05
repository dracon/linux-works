# ADR-001: Ubuntu Linux Integration in Corporate Environment

**Status:** Proposed  
**Date:** 2026-04-13  
**Decision makers:** [TBD]  
**Category:** Infrastructure / Endpoint Management

---

## Context

The organization currently operates a hybrid endpoint environment with Windows and macOS clients, managed through Microsoft Intune with Entra ID as the identity provider. There is a growing need to support Linux workstations — primarily for development and infrastructure work.

Multiple Linux distributions were considered (Ubuntu, CachyOS, Kali Linux). Ubuntu was selected as the first distribution to integrate due to Microsoft's official support for it in both Intune and Defender for Endpoint.

## Decision

We will integrate Ubuntu (22.04 LTS and 26.04 LTS) as a managed corporate endpoint alongside Windows and macOS, using the existing Entra ID and Intune infrastructure.

### The integration consists of:

1. **Identity:** Entra ID device registration via Microsoft Edge sign-in
2. **Compliance:** Intune Linux compliance policies (OS version, LUKS encryption, Defender status)
3. **Security:** Microsoft Defender for Endpoint on Linux for threat detection and reporting
4. **Browser:** Microsoft Edge as the primary browser, enabling SSO and device-based Conditional Access
5. **Configuration management:** Ansible for settings beyond Intune's scope (firewall, SSH hardening, certificates, packages)
6. **File access:** M365 web apps via Edge; OneDrive access via rclone or browser
7. **Onboarding:** Standardized shell script (`setup-corporate-ubuntu.sh`) to automate provisioning

### Conditional Access policy

A dedicated CA policy targeting the Linux platform will be created, requiring:

- Device marked as compliant in Intune
- Multi-factor authentication
- Access scoped to M365 and approved corporate applications

## Alternatives Considered

| Alternative | Reason for rejection |
|---|---|
| Support all Linux distros equally | Only Ubuntu has official Microsoft support for Intune and Defender. Other distros would be unmanageable with current tooling. |
| Third-party UEM (e.g., Fleet, JAMF) | Adds cost and complexity. Intune's Linux support, while limited, covers the essentials and avoids a second management plane. |
| Treat Linux as unmanaged BYOD | Unacceptable security posture for devices accessing corporate resources. |
| Wait for broader Intune Linux support | Business need exists now. The current feature set (compliance + Defender) is sufficient for a first phase. |

## Consequences

### Positive

- Developers and infrastructure engineers get supported Linux workstations
- Single identity provider (Entra ID) across all platforms
- Consistent security baseline (Defender, encryption, compliance) on Linux
- Automated onboarding reduces provisioning time

### Negative

- Intune compliance scope on Linux is narrow compared to Windows/macOS (no app deployment, no full device wipe)
- No official OneDrive sync client for Linux — users must use web or rclone
- Ansible introduces a second configuration management layer alongside Intune
- Only Ubuntu LTS is supported — other distros remain outside scope

### Risks

| Risk | Mitigation |
|---|---|
| Microsoft drops or reduces Linux support in Intune | Monitor Microsoft roadmap. Ansible covers config management independently. |
| Users install unsupported distros and expect corporate access | Clear policy: only Ubuntu LTS is a managed platform. Other distros get BYOD/restricted access. |
| Ansible drift from desired state | Implement scheduled Ansible runs or integrate with CI/CD for drift detection. |
| LUKS encryption not enabled on existing machines | Pre-flight check in onboarding script warns user. Document re-installation procedure if needed. |

## Compliance

- Intune checks: OS version, disk encryption (LUKS), Defender running
- Conditional Access enforces MFA and device compliance before granting resource access
- SSH hardened (no root login, no password auth) via onboarding script
- UFW firewall enabled by default
- Automatic security updates via unattended-upgrades

## Scope Limitation

This ADR covers **Ubuntu LTS only**. CachyOS, Kali Linux, and other distributions are explicitly out of scope for managed access. If these are needed (e.g., for penetration testing), a separate ADR should address network segmentation and BYOD access policies for unmanaged Linux devices.
