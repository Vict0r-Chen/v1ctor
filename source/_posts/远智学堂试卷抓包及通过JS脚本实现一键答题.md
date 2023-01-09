---
title: 远智学堂期末考试之试卷抓包及通过JS脚本实现一键答题
tags:
  - Geek
  - 远智学堂
categories:
  - 实用技能
abbrlink: 625924666
date: 2023-01-08 16:27:01
---

因为参加了远智的学历提升计划，要参加期末考试，我选的这个专业每次还要考十六个科目😢，因为专业不相关，所以也没计划去深入学习。又因为考试时不能打开他们手机端的APP题库，所以很多人都得先在手机上一个题目一个题目的截图，如果是我，得截16科*每科30道题≈480张图，然后还没法搜索...本着节省时间的宗旨，不得出此下策，另外为了方便其他有这方面需求的同学，特别发出这篇blog~

<!-- more -->

## 目的

通过APP抓包远智题库，将题库以json文件储存，然后通过JS脚本点击自动选择提选项来实现自动答题。

## 抓包

### 电脑端下载并激活Charles抓包工具

1. [点击下载安装包](https://www.charlesproxy.com/download/)
2. 打开Charle - Help - Register Charles，任意输入字符（如`Victor`）；
3. [点击进入](https://www.zzzmode.com/mytools/charles/)生成激活密钥的网址；
4. 在网页中输入刚才的字符，点击生成即会生成密钥（如`1ea1b0ced9c48f26b2`)，复制到Charles粘贴进去确认即可；
5. 在左下角的`Fliter`输入远智题图API的URL`https://onlineexam.yzou.cn`；

### IOS端配置代理与HTTPS证书

1. 在控制台中输入`ipconfig`查询当前电脑IP，将ip地址以及端口`8888`在手机上配置为代理：Settings - WLAN - Wifi详情 - Configure Proxy；

2. 在手机上访问`chls.pro/ssl`，进入页面会立刻提示此网站尝试下载证书，点击允许即可；

3. 下载成功后打开IOS Setting应用，第一项菜单应该就是`Profile Downloaded`，进去后点击`Install`然后输入锁屏密码；

4. IOS 10.3系统及以上，需要在 Settings - General - About - Certificate Trust Settings里面找到`Charles Proxy CA({当前日期}, {电脑名称})`，打开信任开关即可；

5. Charles设置Proxy，Proxy -> SSL Proxying Settings...，接着弹框里勾选Enable SSL Proxying，点击`Include`列表下的`Add`，host填`onlineexam.yzou.cn`，Port填`443`，点击OK即可；

{% asset_img ssl-add.png %}

至此在远智APP访问考试相关的HTTPS请求就可以在`Charles`中看到了


### 手机端打开试卷

这里非常简单，在远智APP - 学堂 - 智能练题  - **选中要考试的科目** - 整卷练习 - 背题模式，点击**查看**进去

### Charles查看试卷答案

进入试卷界面后在Charles查找`getFullPaperInfo.do`请求即可。如下图可以看到其中一个单选题的题目、选项及答案：

{% asset_img getFullPaperInfo.png %}

JSON内容应该是这样：
``` json
{
	"code": "00",
	"body": {
		"referenceTime": 1673101544933,
		"paperBaseInfo": {...},//试卷信息
		"examHeadlineDetail": [...]//考题信息
	},
	"msg": "",
	"rspTime": 1673101544933,
	"ok": true
}
```

题库准备完成后就可以根据题库的Json文件生成JS脚本然后在浏览器中执行来达到自动选择答案的目的啦😎

## 生成脚本

老办法，将上面抓到JSON粘贴到输入框，点击升级就会生成JS脚本，然后点击复制，去远智在线的考试界面，按F12打开控制台将脚本粘贴进去回车就好~

{% raw %}
<script>
    function LetterToNumber(letter) {
        switch (letter) {
            case "A":
                return 0;
            case "B":
                return 1;
            case "C":
                return 2;
            case "D":
                return 3;
            case "E":
                return 4;
            case "F":
                return 5;
            case "G":
                return 6;
            case "H":
                return 7;
            default:
                alert("ERROR: " + letter);
                return -1;
        }
    }
    function setOutput(msg){
      document.getElementById("result").innerText=msg;
    }
    function getJsPaperInfo(jsonData){
      var output = "";
      jsonData.body.examHeadlineDetail.forEach(element => {
          output += "\n//" + element.headlineTitle + "\n";
          if (element.headlineTitle == "单选题") {
              for (let index = 0; index < element.examPaperChildVOList[0].examPaperTopicVOList.length; index++) {
                  const item = element.examPaperChildVOList[0].examPaperTopicVOList[index];
                  let anwser = LetterToNumber(item.result);
                  console.log(`${item.topicStems}:${item.result} `);
                  output += (`document.querySelectorAll("#singleCurrentTo${index} .el-radio")[${anwser}].click();\n`);
              }
          } else if (element.headlineTitle == "多选题") {
              for (let index = 0; index < element.examPaperChildVOList[0].examPaperTopicVOList.length; index++) {
                  const item = element.examPaperChildVOList[0].examPaperTopicVOList[index];
                  console.log(`${item.topicStems}:${item.result}`);
                  for (let ss = 0; ss < item.result.length; ss++) {
                      const letters = item.result[ss];
                      let anwser = LetterToNumber(letters);
                      output += (`await document.querySelectorAll("#moreTopicInfo${index} .el-checkbox")[${anwser}].click();\n`);
                  }
              }
          } else if (element.headlineTitle == "判断题") {
              for (let index = 0; index < element.examPaperChildVOList[0].examPaperTopicVOList.length; index++) {
                  const item = element.examPaperChildVOList[0].examPaperTopicVOList[index];
                  let anwser = LetterToNumber(item.result);
                  console.log(`${item.topicStems}:${item.result} ${anwser}`);
                  output += (`document.querySelectorAll("#judgeTopicInfo${index} .el-radio")[${anwser}].click();\n`);
              }
          } else if (element.headlineTitle == "填空题") {
              output += `function gapAQ(selector, text){var elements = document.querySelectorAll(selector);return Array.prototype.filter.call(elements, function(element){return RegExp(text).test(element.textContent);});};`;
              for (let index = 0; index < element.examPaperChildVOList[0].examPaperTopicVOList.length; index++) {
                  const item = element.examPaperChildVOList[0].examPaperTopicVOList[index];
                  let anwser = JSON.parse(item.result);
                  for (let prop in anwser) {
                      console.log(prop);
                      let iii = parseInt(prop.replace('result', '')) - 1;
                      output += (`gapAQ('p','${element.headlineTitle}')[0].parentElement.querySelectorAll("#gapTopicInfo${index} > div.quill_box > div.el-row > div.quill-editor > div.ql-container.ql-snow > div.ql-editor")[${iii}].innerText="${anwser[prop]};"\n`);
                  }
              }
          } else if (element.headlineTitle == "名词解释题") {
              output += `function nounAQ(selector, text){var elements = document.querySelectorAll(selector);return Array.prototype.filter.call(elements, function(element){return RegExp(text).test(element.textContent);});};`;
              for (let index = 0; index < element.examPaperChildVOList[0].examPaperTopicVOList.length; index++) {
                  const item = element.examPaperChildVOList[0].examPaperTopicVOList[index];
                  output += (`nounAQ('p','${element.headlineTitle}')[0].parentElement.querySelector("#qaTopicInfo${index} > div.quill_box > div.el-row > div.quill-editor > div.ql-container.ql-snow > div.ql-editor").innerText="${item.result};"\n`);
              }
          } else {
              alert(`存在不支持的题型[${element.headlineTitle}]，请自行检查！`);
          }
      });
      return output;
    }
    function generate(){
        let jsonStr = document.getElementById("txtJson").value;
        try{
          let paperInfo = JSON.parse(jsonStr)
          console.log({paperInfo})
          let output = getJsPaperInfo(paperInfo);
          setOutput(output);
        }
        catch(e){
          console.error(e);
          setOutput(`JSON格式有误`);
        }
    }
    function copyResult(){
      let result = document.getElementById("result").innerText;
      navigator.clipboard.writeText(result);
      alert("复制成功");
    }
</script>
<div style="background:#23507f23; padding:10px; border-radius: 10px;margin: 10px 20px;">
   <p style="text-align:center;margin-bottom:10px;">
      <strong>1. 将JSON内容粘到输入框</strong>
   </p>
   <div>
      <textarea id="txtJson" style="width:100%; height:100px"></textarea>
   </div>
   <div>
      <button onclick="generate()">2. 点击生成脚本</button>
      <hr/>
      <div id="result"></div>
      <button onclick="copyResult()">3. 复制</button>
   </div>
</div>
<style>
    .text-wrapper {
        white-space: pre-wrap;
    }
    #result{
      height: 140px;
      overflow: scroll;
      overflow-x: hidden;
    }
</style>
{% endraw %}

## 突破考试时间至少要5分钟的限制

其实我本来觉得这个限制应该没法突破的，因为在后台稍微判断一下就可以做到，意想不到的是这个判断逻辑竟然坐在前端😢是我想多了（当然，也可能是同行心存善意🤣🤣）

既如此，打开控制台，在`source`下的`webpack://`找到`newOnlineExam.vue`，在大概`1300`行处打个断点，页面里点击"交卷"时会命中此断点，然后将`rspTime`改大一点即可（我是把第一位的1改成2就好了）。

{% asset_img limit.png %}

## 注意事项

由于很多简答题没有答案，并且问题的顺序也不一致，所以对于简答题就需要自行谷歌，或者使用ChatGPT（吹爆！！！）来生成答案😉

**郑重声明：使用时请自行核对答案，考0分我可不管啊**