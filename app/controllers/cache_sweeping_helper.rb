module CacheSweepingHelper

  def expire_cached_page(web, page_name)
    expire_action :controller => 'wiki', :web => web.address,
        :action => %w(show published tex print history source), :id => page_name
    expire_action :controller => 'wiki', :web => web.address,
        :action => 'show', :id => page_name, :mode => 'diff'
  end

  def expire_cached_summary_pages(web)
    categories = WikiReference.list_categories(web)
    list_of_actions = %w(list recently_revised)
    if web.address == 'nlab'
      list_of_actions.delete('recently_revised')
    end
    list_of_actions.each do |action|
      expire_action :controller => 'wiki', :web => web.address, :action => action
      categories.each do |category|
        expire_action :controller => 'wiki', :web => web.address, :action => action, :category => category
      end
    end

    %w(authors atom_with_content atom_with_headlines atom_with_changes file_list).each do |action|
      expire_action :controller => 'wiki', :web => web.address, :action => action
    end

    %w(file_name created_at).each do |sort_order|
      expire_action :controller => 'wiki', :web => web.address, :action => 'file_list', :sort_order => sort_order
    end
  end

  def expire_recently_revised_page(web)
    categories = WikiReference.list_categories(web)
    expire_action :controller => 'wiki', :web => web.address, :action => 'recently_revised'
    categories.each do |category|
      expire_action :controller => 'wiki', :web => web.address, :action => 'recently_revised', :category => category
    end
  end

  def expire_cached_revisions(page)
    page.rev_ids.count.times  do |i|
      revno = i+1
      expire_action :controller => 'wiki', :web => page.web.address,
          :action => 'revision', :id => page.name, :rev => revno
      expire_action :controller => 'wiki', :web => page.web.address,
          :action => 'revision', :id => page.name, :rev => revno, :mode => 'diff'
      expire_action :controller => 'wiki', :web => page.web.address,
          :action => 'source', :id => page.name, :rev => revno
    end
  end

end
