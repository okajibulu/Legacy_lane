export const generateMembershipID = ({ role, branch, cohortYear }) => {
  const prefix = role.charAt(0).toUpperCase();
  const branchCode = branch.replace(/\s+/g, '').substring(0, 3).toUpperCase();
  const year = cohortYear || new Date().getFullYear();
  const random = Math.floor(1000 + Math.random() * 9000);
  return `${prefix}-${branchCode}-${year}-${random}`;
};
