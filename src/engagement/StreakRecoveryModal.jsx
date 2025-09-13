import React from 'react';

const StreakRecoveryModal = ({ onRecover, onCancel }) => (
  <div className="streak-recovery-modal">
    <h3>Recover Your Streak</h3>
    <p>You’ve missed a few days. Use a Grace Token to restore your progress?</p>
    <button onClick={onRecover}>Use Grace Token</button>
    <button onClick={onCancel}>Cancel</button>
  </div>
);

export default StreakRecoveryModal;
