require 'spec_helper'

describe Api::V1::AnimesController do
  describe :show do
    let(:anime) { create :anime }
    before { get :show, id: anime.id }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end
end
