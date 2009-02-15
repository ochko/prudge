class AttachmentController < ApplicationController
  before_filter :login_required

  def create
    @attachment = Attachment.new(params[:attachment])
    return unless validate_permission?
    if @attachment.save
      responds_to_parent do
        render :update do |page|
          page.insert_html :bottom, "attachments",
          :partial => 'attachment/list_item',
          :locals => { :attachment => @attachment}
          page.visual_effect :highlight, "attachment_#{@attachment.id}"
        end
      end
    else
      render :text => 'Хавсралтыг хадгалж чадсангүй!'
    end
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    if !@attachment.nil?
      return unless validate_permission?
      @attachment.destroy
      respond_to do |format|
        format.js
      end
    end
  end

  def download
    @attachment = Attachment.find(params[:id])
    return unless downloadable?
    send_file @attachment.public_filename
  rescue
    render :text => 'Файл олдсонгүй!'
  end

  private
  def validate_permission?
    attachable = @attachment.attachable
    if attachable.has_permission?(current_user)
      return true
    else
      return false
    end
  end

  def downloadable?
    attachable = @attachment.attachable
    if attachable.available_to(current_user)
      return true
    else
      return false
    end
  end
end
