import React from 'react';

const TokenPreview = ({ tokens }) => (
  <div className="token-preview">
    <h3>Your Token Balance</h3>
    <p>{tokens} tokens</p>
  </div>
);

export default TokenPreview;
