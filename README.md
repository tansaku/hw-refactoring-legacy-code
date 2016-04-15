Homework 5: 
===

Refactoring & Legacy Code
===

You're strongly encouraged to do this assignment as a pair, but you don't have to.  If you do, both will receive the same grade.  We encourage you to try working with someone who might be on your course project team, to see if you work well together pairing.

**Overview: Extending & Fixing Typo**

Typo is a blogging engine written in Rails to allow people to set up a blog easily.  Typo consists of about 30,000 lines of code (30 KLOC) and comes with a ton of features, including authentication to post to the blog, attaching files to articles, adding special markup, creating custom themes, building user profiles, and allowing guests and/or users to comment on posts.  It also supports more advanced features like trackbacks (allowing other blogs to “track back” to yours and mention you in their blog article).

From your perspective, Typo is legacy code since you didn't write it yourself :-)  In this assignment you'll go through the steps of adapting the BDD+TDD cycle to enhance and fix a bug in a piece of legacy code.

Preview of structure of assignment:

* Get the legacy software running, kick the tires (play around with Typo yourself), and make sure its existing test suite runs correctly, to establish a baseline.
* Create cucumber stories based on mockup that we will provide for a new Typo feature: article merging. These stories will serve as high-level integration/acceptance tests.
* Use stories to drive the process of identifying where in Typo things will have to be modified, which in turn will tell you where to create new model and controller specs (we will not require view specs, although we would encourage them) to support the functionality. These specs will serve as low-level unit tests for the code we are adding.
* Drive creation of new feature code from step 1's scenarios plus rspec tests; will need to use fixtures and/or factories to create content for tests.
* Examine the bug in typo.
* Write cucumber stories to test the behavior of the bug.
* Write a bugfix that passes the cucumber stories you created in step 6.

In Part 1, you'll get familiar with Typo, create cucumber tests, and implement the particle merge feature (steps 1-4 above). In part 2, you’ll examine and fix a bug in Typo, writing tests to prevent future regressions along the way (steps 5-7 above).

**Part 0: Getting set up**

In these steps you'll download Typo, get it running on your local system, verify that its test suite passes, and do a test deployment to Heroku.  You'll also setup an account on Pivotal Tracker, which you'll use to setup tasks for part 2.

   1.Install Typo locally

   2.Get the Typo test suite and make sure all specs pass green.

   3.Create a GitHub repo for your code (recommended; at the very least, create a Git repo locally) and push to it.

   4.Setup a free Pivotal Tracker account, create a public project for this assignment, and add your pair partner as a collaborator (obviously only 1 of the pair needs to do this if pairing).  

   5.Make sure Typo can be deployed to Heroku.

**Typo + GitHub Setup Instructions**


1. [Fork](https://help.github.com/articles/fork-a-repo) the Typo repository: https://github.com/saasbook/typo  (Typo is open source, but we have snapshotted the repo including fixing some failing tests and using a stable revision for Ruby 1.9.2)

2. Now clone your forked Typo repository into a folder on your local machine.

3. Run bundle install --without production in the Typo directory.

4. Run the database migration in the Typo directory (rake db:migrate).

5. Load the seed data into the database (rake db:seed).
   
6. Run rake spec and rake cucumber in the Typo directory to ensure that your tests all pass. Pending specs are fine.

**Deploying to Heroku Instructions**

Typo wasn’t built with Heroku in mind, but the changes needed to deploy to Heroku have already been made in our fork of the Typo repository. From within your copy of the Typo repository, run:

```
heroku create 
git push heroku master 
heroku run rake db:migrate 
heroku run rake db:seed
```

**1. Specify features**

We want to add a useful feature called article merging.  When there are multiple bloggers on one site, the authors may write more than one article on the same topic and say similar things.  The user will be able to visit the article view, and, if they are an admin, there should be a form on that article’s edit page that allows an administrator to enter in the ID of another article to merge the current article with.  When this happens, we want to preserve both articles’ content, but merge them together into one article. You should verify that both specified articles exist, and that they are not the same article.

**Scenarios**: 

To do this properly, we want to keep the following in mind:

1. A non-admin cannot merge articles.

2. When articles are merged, the merged article should contain the text of both previous articles.

3. When articles are merged, the merged article should have one author (either one of the authors of the original article).  

4. Comments on each of the two original articles need to all carry over and point to the new, merged article.

5. The title of the new article should be the title from either one of the merged articles.

Start by **writing cucumber scenarios for the above behaviors.** You will probably want to put them in separate feature files. You may add them to the existing feature files. Over the rest of part 1 and all of part 2 we will make these go green.

Below is a mockup for the merge articles interface [hi-res]. The form for merging articles should be on the edit page for an article and it should let the user input the id of the article to be merged with. The merge interface should not be presented for new articles nor to non-administrators, but it is fine for the merge articles functionality to be present for drafts (we will not conduct any tests using draft articles). **Make sure that the form field containing the ID of the article to merge has the name ‘merge_with’.**

Tip: Nesting <form> tags is invalid in HTML. Most browsers will only accept the outermost form tag. Be careful of which views you edit: a view partial may be rendered while inside of another form tag, so creating another form inside of it would be invalid.
2. Start driving changes through specs
===
**Due Sunday, November 3rd, 11:59 PM**

Starting with scenarios 1 and 2 above, you will start creating the cucumber tests to drive the code changes to implement each scenario. The second one will be toughest, because you will have to create the basic functionality that allows merging to happen. Subsequent specs will be easier, as you start adding specs and code to meet the criteria spelled out in scenarios 3-4. You should put your cucumber tests in a new file. 

For scenarios 1 and 2:

1. Start by implementing the step definitions that will show an admin (but not a regular user) a "Merge With This Article" button which, when clicked, will dispatch to a controller action that does the merge.

2. Let those step definitions drive the creation of controller specs, as we did in the example in ELLS chapter 5.  Obviously the merging functionality itself should go in the model, not the controller, so feel free to assume an instance method of the Article model merge_with(other_article_id).  Eventually, this method will return an article object that is the merged article, and also handles all of the considerations above. Get these specs to pass green.  Commit.

Warning: ActiveRecord caches associations. If you load an article from the database, reassign its comments to some other article, then destroy the first article, the comments may be destroyed as well even if the actual database says that the article doesn’t own the comments anymore. This is because at the time the article was originally read from the database, the knowledge about which comments that article owned was read as well (cached), and this knowledge was not updated when the comments were reassigned nor when the article was destroyed.
 
When you are finished, you should have the following:

Typo passing green all specs

Specs to verify that the controller behaves correctly when non-admins attempt to merge articles passing green.

Specs to verify that the model’s merge method combines the given articles correctly passing green.

Modifications to the models, views, and controllers necessary to merge articles

Cucumber scenarios "A non-admin cannot merge two articles" and “When articles are merged, the merged article should contain the text of both previous articles” passing green

All the above committed to Git and pushed to your GitHub repo

Good job! At this point you are ready to submit part 1 of homework 5. Follow the submission instructions on edX.
3. Fixing a bug in Typo
===
**Due Sunday, November 10th, 11:59 PM**

The version of typo you have checked out contains a bug that prevents categories from being created or edited. To see this bug, make sure you are logged in as an administrator and click on the “categories” link on the left hand side of the admin page. The page is intended to look as follows:

This page is intended to allow you to add and edit blogging categories. Fix this bug by writing cucumber tests that fail when this bug is present and pass when you can successfully edit existing categories and create new categories.

Congratulations! You are all done with the legacy code assignment. See edX for the submission instructions.

