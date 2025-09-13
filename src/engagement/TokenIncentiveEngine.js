export const calculateReactivationBonus = (daysInactive) => {
  if (daysInactive >= 14) return 10;
  if (daysInactive >= 30) return 20;
  return 0;
};

export const applyTokenBonus = (user, bonus) => {
  user.tokens += bonus;
  return user;
};
