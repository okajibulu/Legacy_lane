import React, { useState } from 'react';

const MemberRegistrationForm = () => {
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    role: '',
    branch: '',
    cohortYear: '',
    referralCode: ''
  });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    // TODO: Send formData to backend API
    console.log('Submitting:', formData);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input name="fullName" placeholder="Full Name" onChange={handleChange} required />
      <input name="email" type="email" placeholder="Email" onChange={handleChange} required />
      
      <select name="role" onChange={handleChange} required>
        <option value="">Select Role</option>
        <option value="student">Student</option>
        <option value="staff">Staff</option>
        <option value="alumni">Alumni</option>
        <option value="general">General Member</option>
      </select>

      <input name="branch" placeholder="Branch/Institution" onChange={handleChange} required />
      <input name="cohortYear" type="number" placeholder="Cohort Year (e.g. 2025)" onChange={handleChange} />
      <input name="referralCode" placeholder="Referral Code (optional)" onChange={handleChange} />

      <button type="submit">Register</button>
    </form>
  );
};

export default MemberRegistrationForm;
