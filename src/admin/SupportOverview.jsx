import React from 'react';

const SupportOverview = ({ tickets }) => (
  <div className="support-overview">
    <h2>Support Tickets</h2>
    <p>Open: {tickets.open}</p>
    <p>Resolved: {tickets.resolved}</p>
    <p>Pending: {tickets.pending}</p>
  </div>
);

export default SupportOverview;
