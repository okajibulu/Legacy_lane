import React from 'react';

const BadgeShowcase = ({ badges }) => (
  <div className="badge-showcase">
    <h3>Your Badges</h3>
    {badges.length === 0 ? (
      <p>No badges yet. Start earning by engaging!</p>
    ) : (
      <ul>{badges.map((badge, i) => <li key={i}>{badge}</li>)}</ul>
    )}
  </div>
);

export default BadgeShowcase;
