# frozen_string_literal: true

RSpec.shared_examples_for 'name attribute owner' do
  describe 'attributes' do
    it { is_expected.to respond_to(:name) }
  end

  describe '#name' do
    it 'validates presence' do
      expect(subject).not_to be_valid
      expect(errors).to include('Name can\'t be blank')
    end

    it 'accepts valid' do
      subject.name = 'Google'

      expect(subject).to be_valid
    end
  end
end
