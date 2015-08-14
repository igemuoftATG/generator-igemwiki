<div  id='top_menu_inside'>

<ul>
<li class='has_submenu'><a href='' style='color:white'>iGEM</a><div class='submenu'>
                   <div id='igem_submenu' class='intro'>Loading the iGEM menu ...</div>
               </div>
               <script>jQuery('#igem_submenu').load('http://2015.igem.org/cgi/top_menu_14/igem_reply.cgi',{t: '', a: ''});</script></li>
<li class='has_submenu'><a href='' style='color:white'>wiki tools</a><div class='submenu'>
                   <div id='wiki_tools_submenu' class='intro'>Loading the wiki tools menu ...</div>
               </div>
               <script>jQuery('#wiki_tools_submenu').load('http://2015.igem.org/cgi/top_menu_14/wiki_tools_reply.cgi',{t: '', a: ''});</script></li>
<li class='has_submenu'><a href='' style='color:white'>search</a><div class='submenu'>
                   <div id='search_submenu' class='intro'>Loading the search menu ...</div>
               </div>
               <script>jQuery('#search_submenu').load('http://2015.igem.org/cgi/top_menu_14/search_reply.cgi',{t: '', a: ''});</script></li>
<li class='has_submenu'><a href='' style='color:white'>toc</a><div class='submenu'>
                   <div id='toc_submenu' class='intro'>Loading the toc menu ...</div>
               </div>
               <script>jQuery('#toc_submenu').load('http://2015.igem.org/cgi/top_menu_14/toc_reply.cgi',{t: '', a: ''});</script></li>
<li class='has_submenu'><a href='' style='color:white'>teams</a><div class='submenu'>
                   <div id='teams_submenu' class='intro'>Loading the teams menu ...</div>
               </div>
               <script>jQuery('#teams_submenu').load('http://2015.igem.org/cgi/top_menu_14/teams_reply.cgi',{t: '', a: ''});</script></li>
</ul>
 <div id='user_item' class='has_submenu' >login</div>
           <script>jQuery('#user_item').load('http://2015.igem.org/cgi/top_menu_14/user_reply.cgi',{t: ''});</script>
<script>bars_box_active = true;</script>
<div id='bars_item'>  <img src='http://parts.igem.org/images/website/bars_20.png' style='height:14px;width:20px;'>  <div id='bars_box' style='display:none;'>Loading...</div></div><script>jQuery('#bars_box').load('http://2015.igem.org/AJ:Bars_Box?action=raw',{t: '', o: ''});jQuery('#bars_item img')
               .click(function() {
                          if ( bars_box_active ) {
                              jQuery('#bars_box').toggle(); 
                              if ( jQuery('#bars_box').css('display') == 'block' ) {
                                   jQuery('#bars_item').css('backgroundColor','rgb(255, 165, 0)');
                              } else {
                                   jQuery('#bars_item').css('backgroundColor','');
                              }
                          }
                      } );</script></div><script>
jQuery('#top_menu_14 .has_submenu').hover(
    function() {
        jQuery(this).find('.submenu').show();
    },
    function() {
        jQuery(this).find('.submenu').clearQueue();
        jQuery(this).find('.submenu').hide();
        jQuery(this).find('.submenu').clearQueue();
        jQuery(this).find('.submenu').hide();
    } 
);
</script>