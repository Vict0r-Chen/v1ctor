{%- if page.comments %}
<script>
NexT.utils.loadComments(document.querySelector('#utterances-container'), () => {
    // if (typeof parcelRequire === 'function') { return; }
    var js = document.createElement('script');
    js.type = 'text/javascript';
    js.src = 'https://utteranc.es/client.js';
    js.async = true;
    js.crossorigin = 'anonymous';
    js.setAttribute('repo', '{{ theme.utterances.repo }}');
    js.setAttribute('issue-term', '{{ theme.utterances.issue_term }}');
    js.setAttribute('theme', '{{ theme.utterances.theme }}');
    document.getElementById('utterances-container').appendChild(js);
});
</script>
{%- endif %}
