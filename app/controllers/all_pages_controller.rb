require "json"

class AllPagesController < ApplicationController
  layout "default", :except => []

  def all
    @name_text = name_text(@web.name)
    @all_pages = all_pages_in_web(@web.id)
    @number_of_pages = @all_pages.count
    @has_categories = has_categories?(@web.id)
    return
  end

  def all_in_category
    category_name = params["category"]
    if !nlab_category?(@web.id, category_name)
      web_name_text = name_text(@web.name)
      render(
        :status => 404,
        :template => "/errors/404.rhtml")
      return
    end
    @name_text = name_text(@web.name)
    @all_pages_in_category = all_pages_in_category(@web.id, category_name)
    @number_of_pages = @all_pages_in_category.count
    @category_name = category_name
    return
  end

  def link_to_web_page(page)
    if @web.published?
      "https://ncatlab.org/" + @web_name + "/published/" + URI.encode(page)
    else
      "https://ncatlab.org/" + @web_name + "/show/" + URI.encode(page)
    end
  end

  helper_method :link_to_web_page

  def link_to_all_categories_page()
    "https://ncatlab.org/" + @web_name + "/page_categories"
  end

  helper_method :link_to_all_categories_page

  private

  def all_pages_in_web(web_id)
    all_pages_binary = File.join(
      Rails.root,
      "script/all_pages")
    pages = %x(
      "#{all_pages_binary}" "#{web_id}")
    JSON.parse(pages)
  end

  def all_pages_in_category(web_id, category_name)
    all_pages_binary = File.join(
      Rails.root,
      "script/all_pages")
    pages = %x(
      "#{all_pages_binary}" "#{web_id}" --category "#{category_name}")
    JSON.parse(pages)
  end

  def name_text(web_name)
    if web_name == "nLab"
      return "The nLab"
    elsif nlab_author?(web_name)
      return "The personal wiki of " + web_name
    else
      return "The " + web_name + " wiki"
    end
  end

  def nlab_author?(possible_author)
    author_contributions_binary = File.join(
      Rails.root,
      "script/author_contributions")
    is_nlab_author = %x(
      "#{author_contributions_binary}" is_author "#{possible_author}")
    is_nlab_author.strip! == "True" unless is_nlab_author.nil?
  end

  def nlab_category?(web_id, possible_category)
    page_categories_binary = File.join(
      Rails.root,
      "script/page_categories")
    is_nlab_category = %x(
      "#{page_categories_binary}" is_category "#{web_id}" "#{possible_category}")
    is_nlab_category.strip! == "True" unless is_nlab_category.nil?
  end

  def has_categories?(web_id)
    page_categories_binary = File.join(
      Rails.root,
      "script/page_categories")
    has_categories = %x(
      "#{page_categories_binary}" has_categories "#{web_id}")
    has_categories.strip! == "True" unless has_categories.nil?
  end
end
