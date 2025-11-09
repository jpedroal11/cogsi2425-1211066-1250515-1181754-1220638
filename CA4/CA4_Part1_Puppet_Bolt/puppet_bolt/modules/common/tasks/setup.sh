#!/bin/bash
# Common setup: users, groups, PAM policy

set -e

echo "Creating developers group..."
if ! getent group developers > /dev/null 2>&1; then
  groupadd -g 3000 developers
  echo "  ✓ Group 'developers' created (GID 3000)"
else
  echo "  ✓ Group 'developers' already exists"
fi

echo "Creating devuser..."
if ! id devuser > /dev/null 2>&1; then
  useradd -u 3000 -g developers -m -s /bin/bash devuser
  echo "  ✓ User 'devuser' created (UID 3000)"
else
  echo "  ✓ User 'devuser' already exists"
fi

echo "Installing PAM packages..."
apt-get update -qq
apt-get install -y -qq libpam-pwquality libpam-modules > /dev/null
echo "  ✓ PAM packages installed"

echo "Configuring password quality policy..."
cat > /etc/security/pwquality.conf << 'EOF'
# Puppet Bolt managed file
minlen = 12
minclass = 3
dictcheck = 1
usercheck = 1
enforce_for_root
maxrepeat = 3
maxsequence = 3
EOF
echo "  ✓ Password quality policy configured"

echo "Configuring account lockout policy..."
cat > /etc/security/faillock.conf << 'EOF'
# Puppet Bolt managed file
deny = 5
unlock_time = 600
fail_interval = 900
audit
silent
EOF
echo "  ✓ Account lockout policy configured"

echo "Configuring PAM password history..."
sed -i 's/^password.*pam_unix.so.*/password [success=1 default=ignore] pam_unix.so obscure use_authtok try_first_pass yescrypt remember=5/' /etc/pam.d/common-password
echo "  ✓ Password history configured (last 5 passwords)"

echo "Configuring PAM faillock..."
if ! grep -q "pam_faillock.so preauth" /etc/pam.d/common-auth; then
  sed -i '/pam_env.so/a auth required pam_faillock.so preauth' /etc/pam.d/common-auth
fi
if ! grep -q "pam_faillock.so authfail" /etc/pam.d/common-auth; then
  sed -i '/pam_unix.so/a auth [default=die] pam_faillock.so authfail' /etc/pam.d/common-auth
fi
if ! grep -q "pam_faillock.so authsucc" /etc/pam.d/common-auth; then
  sed -i '/pam_faillock.so authfail/a auth sufficient pam_faillock.so authsucc' /etc/pam.d/common-auth
fi
echo "  ✓ PAM faillock configured"

echo ""
echo "Common configuration completed successfully!"

