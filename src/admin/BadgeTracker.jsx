import React from 'react';

const BadgeTracker = ({ badges }) => (
  <div className="badge-tracker">
    <h2>Badge Distribution</h2>
    <ul>
      {badges.map((badge, i) => (
        <li key={i}>{badge.name}: {badge.count} awarded</li>
      ))}
    </ul>
  </div>
);

export default BadgeTracker;
