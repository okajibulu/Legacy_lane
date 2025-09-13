import React from 'react';

const TokenFlow = ({ stats }) => (
  <div className="token-flow">
    <h2>Token Activity</h2>
    <p>Total Tokens Earned: {stats.earned}</p>
    <p>Total Tokens Redeemed: {stats.redeemed}</p>
    <p>Donations Made: {stats.donated}</p>
  </div>
);

export default TokenFlow;
