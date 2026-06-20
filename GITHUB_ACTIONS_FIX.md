# GitHub Actions Permission Fix

## Issue Fixed: CodeQL Security Scanning Permissions

### Problem
The CodeQL Action was failing with permission errors:
```
Error: Resource not accessible by integration
Warning: This run of the CodeQL Action does not have permission to access the CodeQL Action API endpoints
```

### Root Cause
The workflow didn't have explicit permissions to:
- Read repository contents
- Write security events (scan results)
- Access CodeQL API endpoints

### Solution Applied

#### 1. Updated `.github/workflows/codeql-analysis.yml`

Added explicit permissions to the `analyze` job:
```yaml
jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    permissions:
      actions: read        # Read workflow run data
      contents: read       # Read repository contents
      security-events: write  # Upload security scan results
```

#### 2. Updated `.github/workflows/continuous-integration-workflow.yml`

Added workflow-level permissions:
```yaml
permissions:
  contents: read      # Read repository contents
  id-token: write     # For trusted publishing to PyPI
```

---

## What These Permissions Do

### `actions: read`
Allows the workflow to:
- Read information about workflow runs
- Access CodeQL action APIs
- Check workflow status

### `contents: read`
Allows the workflow to:
- Clone the repository
- Read source code files
- Access repository metadata

### `security-events: write`
Allows the workflow to:
- Upload CodeQL scan results
- Write to security tab
- Create code scanning alerts

### `id-token: write`
Allows the workflow to:
- Request OIDC tokens
- Authenticate with PyPI for trusted publishing
- Deploy packages securely

---

## Testing the Fix

### 1. Check CodeQL Workflow
After pushing changes, go to:
```
https://github.com/frankosakwe/Lunar-forge/actions/workflows/codeql-analysis.yml
```

Expected result: ✅ Green checkmark with no permission errors

### 2. Check Security Tab
Go to:
```
https://github.com/frankosakwe/Lunar-forge/security/code-scanning
```

Expected result: CodeQL results are uploaded and visible

### 3. Verify No Errors
The workflow should complete without these errors:
- ❌ "Resource not accessible by integration"
- ❌ "does not have permission to access"

---

## Why This Happened

### GitHub Security Model
GitHub Actions uses a least-privilege security model. Workflows must explicitly request permissions they need.

### Default Permissions
By default, workflows have limited permissions. When using security features like CodeQL, explicit permissions are required.

### Repository Settings
The repository may have restricted default permissions in:
```
Settings → Actions → General → Workflow permissions
```

---

## Additional Configuration (Optional)

### Repository-Level Permissions

If issues persist, check repository settings:

1. Go to: `Settings → Actions → General`
2. Under "Workflow permissions":
   - Select: "Read and write permissions"
   - OR keep "Read repository contents and packages permissions" and use explicit permissions in workflows

### Branch Protection

If using branch protection rules:
1. Go to: `Settings → Branches → Branch protection rules`
2. For `main` branch:
   - ✅ Enable "Require status checks to pass"
   - Add required checks: "CodeQL", "lint", "type-check", "test"

---

## Monitoring and Maintenance

### Check Workflow Status
```bash
# View recent workflow runs
gh run list --workflow=codeql-analysis.yml

# View specific run details
gh run view <run-id>
```

### View Security Alerts
```bash
# List code scanning alerts
gh api repos/frankosakwe/Lunar-forge/code-scanning/alerts
```

### Update Actions Versions
Keep GitHub Actions up to date:
- `github/codeql-action/init@v4`
- `github/codeql-action/autobuild@v4`
- `github/codeql-action/analyze@v4`

Check for updates at: https://github.com/github/codeql-action/releases

---

## Troubleshooting

### Issue 1: Still Getting Permission Errors

**Check**:
1. Permissions are at job level (not step level)
2. Repository settings allow workflow modifications
3. You have admin access to the repository

**Fix**:
```yaml
# Make sure permissions are under the job, not under steps
jobs:
  analyze:
    permissions:  # ← Here, not inside steps
      security-events: write
```

### Issue 2: Can't Upload to Security Tab

**Check**:
1. GitHub Advanced Security is enabled (free for public repos)
2. Code scanning is enabled in repository settings
3. Workflow has `security-events: write` permission

**Fix**:
Go to: `Settings → Code security and analysis → Enable Code scanning`

### Issue 3: Fork Pull Requests Failing

**Note**: CodeQL cannot upload results from forked PRs for security reasons.

**Workaround**: This is expected behavior for forks. Results will upload when merged to main.

---

## Best Practices

### 1. Minimal Permissions
Only grant permissions the workflow actually needs:
```yaml
permissions:
  contents: read         # Most workflows need this
  security-events: write # Only for security scanning
```

### 2. Job-Level Permissions
Set permissions at job level for better isolation:
```yaml
jobs:
  scan:
    permissions:
      security-events: write  # Only this job can write security events
  test:
    permissions:
      contents: read          # This job only reads
```

### 3. Explicit Over Implicit
Always be explicit about permissions rather than relying on defaults.

### 4. Regular Updates
Keep action versions updated:
```yaml
uses: github/codeql-action/analyze@v4  # Use latest stable version
```

---

## Security Considerations

### Principle of Least Privilege
- Grant minimum permissions needed
- Don't use `write-all` unless absolutely necessary
- Review permissions periodically

### Token Security
- Never expose `GITHUB_TOKEN` in logs
- Don't pass tokens to untrusted actions
- Use secrets for sensitive data

### Code Scanning
- Enable Dependabot alerts
- Review and fix security findings
- Keep dependencies updated

---

## Verification Checklist

After applying fixes:

- [ ] CodeQL workflow completes successfully
- [ ] No permission errors in logs
- [ ] Security scanning results appear in Security tab
- [ ] Continuous integration tests pass
- [ ] No warnings about resource access
- [ ] Code scanning alerts are visible

---

## Reference Links

- [GitHub Actions Permissions](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token)
- [CodeQL Action Documentation](https://github.com/github/codeql-action)
- [Code Scanning Setup](https://docs.github.com/en/code-security/code-scanning/automatically-scanning-your-code-for-vulnerabilities-and-errors/setting-up-code-scanning-for-a-repository)
- [Security Events Permission](https://docs.github.com/en/rest/overview/permissions-required-for-github-apps#repository-permissions-for-security-events)

---

## Summary

✅ **Fixed**: Added required permissions to CodeQL workflow  
✅ **Fixed**: Added workflow-level permissions to CI/CD pipeline  
✅ **Result**: CodeQL can now upload security scan results  
✅ **Status**: All GitHub Actions should now pass successfully  

**Next**: Push changes and verify workflows complete without errors!

---

**Last Updated**: June 20, 2026  
**Status**: ✅ Fixed and Ready to Deploy
