RSpec.describe Operation do

  describe "attributes" do
    it{ is_expected.to respond_to(:invoice_num)}
    it{ is_expected.to respond_to(:invoice_date)}
    it{ is_expected.to respond_to(:operation_date)}
    it{ is_expected.to respond_to(:amount)}
    it{ is_expected.to respond_to(:reporter)}
    it{ is_expected.to respond_to(:notes)}
    it{ is_expected.to respond_to(:status)}
    it{ is_expected.to respond_to(:kind)}
    it{ is_expected.to respond_to(:company_id)}
  end

  let(:errors){ subject.errors.full_messages}

  describe "#invoice_num" do
    it "validates presence" do
      validate_presence_with_message("Invoice num can't be blank")
    end

    it "validates uniqueness" do
      persisted_operation = create(:operation)
      subject.invoice_num = persisted_operation.invoice_num

      expect(subject).not_to be_valid
      expect(errors).to include("Invoice num has already been taken")
    end

    it "accepts valid" do
      subject.invoice_num = "S37753"

      validate_and_exclude_match(/Invoice num/)
    end
  end

  describe "#invoice_date" do
    it "validates presence" do
      validate_presence_with_message("Invoice date can't be blank")
    end

    it "validates date" do
      subject.invoice_date = "not a date"

      validate_presence_with_message("Invoice date can't be blank")
    end

    it "accepts valid" do
      subject.invoice_date = "29-04-2015"

      validate_and_exclude_match(/Invoice date/)
    end
  end

  describe "#amount" do
    it "validates presence" do
      validate_presence_with_message("Amount can't be blank")
    end

    it "validates numericallity" do
      subject.amount = "not a number"

      expect(subject).not_to be_valid
      expect(errors).to include("Amount is not a number")
    end

    it "validates positive numbers" do
      subject.amount = -5

      expect(subject).not_to be_valid
      expect(errors).to include("Amount must be greater than 0")
    end

    it "accepts valid" do
      subject.amount = 7

      validate_and_exclude_match(/Amount/)
    end
  end

  describe "#operation_date" do
    it "validates presence" do
      validate_presence_with_message("Operation date can't be blank")
    end

    it "validates date" do
      subject.operation_date = "not a date"

      validate_presence_with_message("Operation date can't be blank")
    end

    it "accepts valid" do
      subject.operation_date = "29-04-2015"

      validate_and_exclude_match(/Operation date/)
    end
  end

  describe "#kind" do
    it "validates presence" do
      validate_presence_with_message("Kind can't be blank")
    end

    it "accepts valid" do
      subject.kind = "negligible"

      validate_and_exclude_match(/Kind/)
    end
  end

  describe "#status" do
    it "validates presence" do
      validate_presence_with_message("Status can't be blank")
    end

    it "accepts valid" do
      subject.status = "other"

      validate_and_exclude_match(/Status/)
    end
  end

  def validate_presence_with_message(msg)
    expect(subject).not_to be_valid
    expect(errors).to include(msg)
  end

  def validate_and_exclude_match(regex)
    expect(subject).not_to be_valid
    expect(errors).not_to include(match(regex))
  end

end
