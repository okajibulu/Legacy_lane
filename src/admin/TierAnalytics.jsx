import React from 'react';

const TierAnalytics = ({ data }) => (
  <div className="tier-analytics">
    <h2>Tier Adoption</h2>
    <ul>
      {data.map((tier, i) => (
        <li key={i}>{tier.name}: {tier.count} communities</li>
      ))}
    </ul>
  </div>
);

export default TierAnalytics;
