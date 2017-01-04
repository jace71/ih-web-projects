<%@ Page Language="C#" Inherits="CrownPeak.Internal.Debug.OutputInit" %>
<%@ Import Namespace="CrownPeak.CMSAPI" %>
<%@ Import Namespace="CrownPeak.CMSAPI.Services" %>
<%@ Import Namespace="Influence_Health_Marketing_Project.Library" %>
<!--DO NOT MODIFY CODE ABOVE THIS LINE-->
<%
	String articleType = "";
	String authorName = "";
	String authorThumbnail = "";
	String authorTitle = "";
	String authorBio = "";
	String authorLink = "";

	// gConfig is used by Blog IndexBuilder
	Asset gConfig = BlogOutputHelper.GetGlobalConfig(asset);

	articleType = asset["article_type"];
	
	// default to 8/4 columns
	String mainContentCols = "8";
	String rightContentCols = "4";

	// if not a blog, default to 6/6
	if (articleType.ToLower() != "blog")
	{
		mainContentCols = "6";
		rightContentCols = "6";
	}
	
	// Only gather author info for blogs
	if (articleType.ToLower() == "blog")
	{
		Asset authorConfig = Asset.Load(asset.Parent.Parent.AssetPath + "/Author Config");
		if (authorConfig.IsLoaded)
		{
			if (!String.IsNullOrWhiteSpace(authorConfig["author_name"]))
			{
				authorName = authorConfig["author_name"];
				authorThumbnail = authorConfig["author_headshot"];
				authorTitle = authorConfig["author_title"];
				authorBio = authorConfig["author_bio"];
			}
		}

		Asset authorAsset = Asset.Load(asset.Parent.Parent.AssetPath + "/default");
		if (authorAsset.IsLoaded)
		{
			authorLink = authorAsset.GetLink();
		}
		else
		{
			Out.DebugWriteLine("Author asset could not be loaded.");
		}
	}
	
	Out.Wrap("/Influence Health/_Internal/Marketing/Influence Health Marketing Project/Templates/Nav Wrap");
%>
<div id="blog-post">

	<!-- Page Title Section -->
	<section id="section-title">
		<div class="row">
			<div class="col-xs-12 text-center stacked-lg">
				<h1><%= asset["title"] //articleType %></h1>
			</div>
		</div>
	</section>
	<div id="blog-post-content">

		<!-- Topics, Share Button and Blog Image (if available) -->
		<section class="image-wrap content-area-standard">
		
			<!-- Topics and Share Button -->
			<div class="topic-share-wrap">
				<div>
					<%
						Out.Write(BlogOutputHelper.GetCategoryLinks(asset));
					%>
				</div>
				<div class="pull-right share-wrap">
					<a href="javascript: toggleAddThis();" class="link-default link-wide">Share</a>
					<div class="addthis_sharing_toolbox" id="shareAddThis" style="display: none;"></div>
					<script type="text/javascript">
						function toggleAddThis() {
							if ($('#shareAddThis').is(":visible")) {
								// hide AddThis
								$('#shareAddThis').fadeOut(1000);
							}
							else {
								// show AddThis
								$('#shareAddThis').fadeIn(1000);
							}
						}
            
            $(document).ready(function() {
              $("#blog-post .image-wrap.content-area-standard .post-image").css("cursor","pointer");
              $("#blog-post .image-wrap.content-area-standard .post-image").click(function() {
                var pageTypeVAR = $("#section-title h1").text();
                var clientStories = "Client Stories";
                var whitePapers = "White Papers";
                if(pageTypeVAR == clientStories) {
                  if ($(".blog-form-wrap").length ) {
                    $('html, body').animate({
                      scrollTop: $(".blog-form-wrap").offset().top
                    }, 1000);
                  }
                }
                else if (pageTypeVAR == whitePapers) {
                  if ($(".blog-form-wrap").length) {
                    $('html, body').animate({
                      scrollTop: $(".blog-form-wrap").offset().top
                    }, 1000);
                  }
                  else if ($("#continue-reading").length) {
                    $('html, body').animate({
                      scrollTop: $("#continue-reading").offset().top
                    }, 1000);
                  }
                  else {
                    // Do Nothing 
                  }
                }
                else {
                  // Do Nothing
                }
              });
            });
            
					</script>
				</div>
			</div>
	
			<!-- Blog Image -->
			<%
				//String postTitle = asset["title"];
	 
				//if(!String.IsNullOrWhiteSpace(asset["top_image"])){
				//	Out.WriteLine(String.Format("<img src=\"{0}\"  alt=\"{1}\" class=\"img-responsive post-image\" />", asset["top_image"], postTitle));
				//}
				//else {
				//	Out.WriteLine("<div class=\"no-post-image-spacer\"></div>");
				//}
			%>
		</section>
	
		<!-- Blog Title -->
		<!--<section class="title-wrap">
			<div class="content-area-standard">
				<h1><%= postTitle %></h1>
			</div>
		</section>-->

		<!-- Blog Post and Form (if exists) -->
		<section class="post-wrap">
			<article class="content-area-standard full-post">
				<div class="row">
					<%
						var hasForm = false;
					
						if(asset.Raw["content_form"].Length > 0){
							hasForm = true;
						}
		
						StringBuilder sb = new StringBuilder();

						if(hasForm){
							if (asset.Raw["primary_content_grid_columns"].Length > 0)
							{
								// set user specified main and right content columns
								mainContentCols = asset.Raw["primary_content_grid_columns"];
								switch (mainContentCols)
								{
									case "4":
										rightContentCols = "8";
										break;
									case "6":
										rightContentCols = "6";
										break;
									default:
										rightContentCols = "4";
										break;
								}
							}
						
							sb.AppendFormat("<div class=\"col-md-{0}\">", mainContentCols);
						}
						else {
							sb.Append("<div class=\"col-xs-12\">");
						}
					
							switch (asset["post_type"])
							{
								case "wysiwyg":
									sb.Append(asset["wysiwyg_content"]);
									sb.AppendLine("");
									break;
								case "text_list":
									List<PanelEntry> listItems = asset.GetPanels("list_item");
									sb.AppendLine("<ul>");
									foreach (PanelEntry listItem in listItems)
									{
										sb.AppendLine(String.Format("<li>{0}</li>", listItem["text_item"]));
									}
									sb.AppendLine("</ul>");
									break;
								case "link_list":
									List<PanelEntry> referenceItems = asset.GetPanels("reference_item");
									sb.AppendLine("<ul>");
									foreach (PanelEntry referenceItem in referenceItems)
									{

										sb.AppendLine(String.Format("<li><h4><a href=\"{1}\">{0}</a></h4>{2}</li>", referenceItem["reference_title"], referenceItem["reference_item_link_link"], referenceItem["reference_description"]));

									}
									sb.AppendLine("</ul>");
									break;
							}
						
						sb.Append("</div>");
					
						if (hasForm)
						{
							sb.AppendFormat("<div class=\"col-md-{0}\">", rightContentCols);
								sb.Append("<div class=\"blog-form-wrap\">");
									sb.Append(asset["content_form"]);
								sb.Append("</div>");
							sb.Append("</div>");
						}
						Out.Write(sb.ToString());
					%>
				</div>
			</article>
		</section>

		<% 
			// Only show Author Bio for blogs
			if(articleType.ToLower() == "blog") {
		%>

		<!-- Author Bio -->
		<section class="bio-wrap">
			<div class="content-area-standard">
				<%
				// topic
                var topicLink = new StringBuilder();
                int totalTopics = 0;
				if (!String.IsNullOrWhiteSpace(asset.Raw["post_category"]))
				{	
                    if (asset.Raw["post_category"].Contains("|"))
                    {
                        //We have a list of categories with a bar delimiter.
                        //Convert list to array, then loop over each and load the asset so we can get the topic name and link.
                        //Add to string topic stringBuilder.
                        var listItems = asset.Raw["post_category"].Split("|".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);
                        int count = 0;
                        foreach (var item in listItems)
                        {
                            Asset category = Asset.Load(item); 
                            count++;
                            if (category.IsLoaded)
                            {
                                topicLink.AppendFormat("<a href=\"{1}\">{0}</a>", category["taxonomy_name"], category.GetLink());
                                if (count < listItems.Count())
                                {
                                    topicLink.Append(", ");
                                }
                            }                           
                        }
                        totalTopics = listItems.Count();
                    }
                    else
                    {
                        Asset category = Asset.Load(asset.Raw["post_category"]);
                        if (category.IsLoaded)
                        {
                            topicLink.AppendFormat("<a href=\"{1}\">{0}</a>", category["taxonomy_name"], category.GetLink());
                            totalTopics = 1;
                        }
                    }
				}
                string topicLabel = "Topic ";
				if (totalTopics > 1)
				{
					topicLabel = "Topics ";
				}
                //output author data. Added schema.org/Person syntax to author data DO NOT REMOVE (itemprop, itemscope, itemtype).
				Out.WriteLine(String.Format("<section class=\"less-top-padding\"><div class=\"info-box\">" +
					"<div class=\"row\"><div class=\"col-xs-12\"><div class=\"bio-links\">{6}{5}</div></div></div>" +
                    "<div class=\"row\" itemprop=\"author\" itemscope=\"\" itemtype=\"http://schema.org/Person\"><div class=\"col-lg-2 col-md-3\">" +
					"<span itemprop=\"image\"><a href=\"{2}\" title=\"Posts by {0}\" rel=\"author\"><img class=\"img-responsive\" alt=\"{0}\" src=\"{1}\" ></a></span></div>" +
					"<div class=\"col-lg-10 col-md-9\">" +
                    "<h4>About the Author</h4><h3><a href=\"{2}\" title=\"Posts by {0}\" rel=\"author\"><span itemprop=\"name\">{0}</span></a></h3>" + 
                    "<p class=\"job-title\" itemprop=\"jobTitle\">{3}</p><p itemprop=\"description\">{4}</p>" +
                    "</div></div></div></section>", authorName, authorThumbnail, authorLink, authorTitle, authorBio, topicLink.ToString(), topicLabel));
				%>
			</div>
		</section>
		<% } %>
		<section id="blog-footer">
			<div class="blogEnd blog-navigation">
				<%
					if (gConfig.IsLoaded) 
					Out.WriteLine("<a href=\"{0}\" class=\"prev\">&lt;</a><a href=\"{0}\">{1} Home</a>", gConfig["blog_home_link"], articleType);
				%> 
			</div>
			<div class="disclaimer">
				<%= gConfig["disclaimer_wysiwyg"]%>
			</div>
		</section>
	</div>
</div>