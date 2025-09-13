import React from 'react';

const ReactivationBanner = ({ name, onDismiss }) => (
  <div className="reactivation-banner">
    <h2>👋 Welcome back, {name}!</h2>
    <p>We missed you. Your legacy journey is still waiting.</p>
    <button onClick={onDismiss}>Dismiss</button>
  </div>
);

export default ReactivationBanner;
