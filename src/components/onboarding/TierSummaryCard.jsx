import React from 'react';

const TierSummaryCard = ({ tier, members, price }) => (
  <div className="tier-card">
    <h2>{tier}</h2>
    <p>Members: {members}</p>
    <p>Price: {price}</p>
  </div>
);

export default TierSummaryCard;
