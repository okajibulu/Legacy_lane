import React from 'react';

const MemberHeatmap = ({ activity }) => (
  <div className="member-heatmap">
    <h2>Member Activity Heatmap</h2>
    <p>Active Members: {activity.active}</p>
    <p>Inactive (14+ days): {activity.inactive}</p>
    <p>New Signups: {activity.new}</p>
  </div>
);

export default MemberHeatmap;
