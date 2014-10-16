# Completed step definitions for basic features: AddMovie, ViewDetails, EditMovie 

Given /^I am on the RottenPotatoes home page$/ do
  visit movies_path
 end


 When /^I have added a movie with title "(.*?)" and rating "(.*?)"$/ do |title, rating|
  visit new_movie_path
  fill_in 'Title', :with => title
  select rating, :from => 'Rating'
  click_button 'Save Changes'
 end

 Then /^I should see a movie list entry with title "(.*?)" and rating "(.*?)"$/ do |title, rating| 
   result=false
   all("tr").each do |tr|
     if tr.has_content?(title) && tr.has_content?(rating)
       result = true
       break
     end
   end  
   assert result
 end

 When /^I have visited the Details about "(.*?)" page$/ do |title|
   visit movies_path
   click_on "More about #{title}"
 end

Then /^(?:|I )should see "([^"]*)"$/ do |text|
  if page.respond_to? :should
    expect(page).to have_content(text)
  else
    assert page.has_content?(text)
  end
end

 When /^I have edited the movie "(.*?)" to change the rating to "(.*?)"$/ do |movie, rating|
  click_on "Edit"
  select rating, :from => 'Rating'
  click_button 'Update Movie Info'
 end


# New step definitions to be completed for HW3. 
# Note that you may need to add additional step definitions beyond these


# Add a declarative step here for populating the DB with movies.
Given /the following movies have been added to RottenPotatoes:/ do |movies_table|
  movies_table.hashes.each do |movie|
    # use the same method used in 'seeds.rb'
	Movie.create!(movie)
  end
end

# filtering steps
When /^I have opted to see movies rated: "(.*?)"$/ do |ratings|
  # remove the comma and split by space
  rating_list = ratings.gsub(/,/,'').split(' ')
  Movie.all_ratings.each do |rating|
    # make id string
  	find_str = sprintf("input[id$='ratings_%s']", rating)
    # only check it if it is in our list
  	find(:css, find_str).set(rating_list.include?(rating))
  end
  # refresh the list
  click_button('Refresh')
end

Then /^I should see only movies rated "(.*?)"$/ do |ratings|
  # remove the comma and split by space
  rating_list = ratings.gsub(/,/,'').split(' ')
  # don't use 'should' it is depricated
  # the second child is the rating
  all('#movies tr > td:nth-child(2)').each do |rating|
    # check that the rating is in the list
	assert(rating_list.include?(rating.text), "The movie with rating #{rating.text} should be included in the ratings: #{rating_list}")
  end
end

Then /^I should see all of the movies$/ do
  # we seed 10 movies in the background
  expected_num_movies = 10
  # don't use 'should' it is depricated
  num_movies = all('#movies tr').count
  # don't forget to add 1 for the header
  assert(num_movies == expected_num_movies + 1, "Expected #{expected_num_movies} got #{num_movies}")
end

# sorting steps
When /^I sort the movies alphabetically$/ do
  # click the title header
  click_link('title_header')
end

When /^I sort the movies by release date$/ do
  # click the release data header
  click_link('release_date_header')
end

Then /^I should see "(.*?)" before "(.*?)"$/ do |before_name, after_name|
  # the 1st child is the name
  all('#movies tr > td:nth-child(1)').each do |name|
     # stop if we find the name that is supposed to come first
     break if name.text == before_name
     # if we run into the second name first then error
     assert(name.text != after_name, "#{after_name} came before #{before_name}");
  end
end
