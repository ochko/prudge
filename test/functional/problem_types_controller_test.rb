require 'test_helper'

class ProblemTypesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:problem_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_problem_type
    assert_difference('ProblemType.count') do
      post :create, :problem_type => { }
    end

    assert_redirected_to problem_type_path(assigns(:problem_type))
  end

  def test_should_show_problem_type
    get :show, :id => problem_types(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => problem_types(:one).id
    assert_response :success
  end

  def test_should_update_problem_type
    put :update, :id => problem_types(:one).id, :problem_type => { }
    assert_redirected_to problem_type_path(assigns(:problem_type))
  end

  def test_should_destroy_problem_type
    assert_difference('ProblemType.count', -1) do
      delete :destroy, :id => problem_types(:one).id
    end

    assert_redirected_to problem_types_path
  end
end
