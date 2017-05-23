RSpec.describe Category do
  let(:errors){ subject.errors.full_messages }

  it_behaves_like "name attribute owner"
end