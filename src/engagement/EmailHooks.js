export const sendReactivationEmail = (user) => {
  const subject = `Welcome back, ${user.name}!`;
  const body = `Hi ${user.name},\n\nWe noticed you've been away. Your legacy journey is still waiting, and we've added a few tokens to help you restart.\n\nLog in today and pick up where you left off.\n\n– Legacy Lane Team`;
  // Replace with actual email service logic
  console.log(`Sending email to ${user.email}:\n${subject}\n${body}`);
};
