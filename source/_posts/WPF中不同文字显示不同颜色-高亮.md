---
title: WPF中不同文字显示不同颜色(高亮)
date: 2022-01-13 10:14:49
tags: [WPF]
---

本文代码来自于 [Stackoverflow](https://stackoverflow.com/questions/751741/wpf-textblock-highlight-certain-parts-based-on-search-condition/60474831#60474831) @`Blechdose`，感谢！
但由于代码不完全满足需求，所以稍改了一下，并未完整封装。

### 功能概述：

实现自动替换`TextBlock`内容中的多个占位符，并将替换后的字符高亮（样式自定义）。
<!--more-->
### 用例：
``` xml
 <!--
    若HighlightTermBehavior处于另外的类库中，则需额外添加此定义:
    xmlns:MyControls="clr-namespace:MyControls;assembly=MyControls"

    另：HighlightTermBehavior.Text和TermToBeHighlighted也可使用动态或静态资源绑定
 -->
 <TextBlock TextWrapping="Wrap" FontWeight="Bold" FontSize="14" Padding="10" TextAlignment="Center"
            MyControls:HighlightTermBehavior.TermToBeHighlighted="PS|Options"
            MyControls:HighlightTermBehavior.Text="Press {0} and {1}">
 </TextBlock>
 ```
### 效果：

{% asset_img 20220113_01.png 效果图 %}

### 源码(`HighlightTermBehavior`)：
``` csharp
namespace MyControls
{
    public static class HighlightTermBehavior
    {
        public static readonly DependencyProperty TextProperty = DependencyProperty.RegisterAttached(
            "Text",
            typeof(string),
            typeof(HighlightTermBehavior),
            new FrameworkPropertyMetadata("", OnTextChanged));

        public static string GetText(FrameworkElement frameworkElement) => (string)frameworkElement.GetValue(TextProperty);
        public static void SetText(FrameworkElement frameworkElement, string value) => frameworkElement.SetValue(TextProperty, value);


        public static readonly DependencyProperty TermToBeHighlightedProperty = DependencyProperty.RegisterAttached(
            "TermToBeHighlighted",
            typeof(string),
            typeof(HighlightTermBehavior),
            new FrameworkPropertyMetadata("", OnTextChanged));

        public static string GetTermToBeHighlighted(FrameworkElement frameworkElement)
        {
            return (string)frameworkElement.GetValue(TermToBeHighlightedProperty);
        }

        public static void SetTermToBeHighlighted(FrameworkElement frameworkElement, string value)
        {
            frameworkElement.SetValue(TermToBeHighlightedProperty, value);
        }


        private static void OnTextChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            if (d is TextBlock textBlock)
                SetTextBlockTextAndHighlightTerm(textBlock, GetText(textBlock), GetTermToBeHighlighted(textBlock));
        }

        private static void SetTextBlockTextAndHighlightTerm(TextBlock textBlock, string text, string termToBeHighlighted)
        {
            textBlock.Text = string.Empty;

            if (string.IsNullOrEmpty(text))
                return;
            //此处使用“|”将需要高亮的字符串分割成参数数组，然后使用string.Format进行格式化，可自行调整
            text = string.Format(text, termToBeHighlighted.Split('|'));

            var textParts = SplitTextIntoTermAndNotTermParts(text, termToBeHighlighted);

            foreach (var textPart in textParts)
                AddPartToTextBlockAndHighlightIfNecessary(textBlock, termToBeHighlighted, textPart);
        }

        private static void AddPartToTextBlockAndHighlightIfNecessary(TextBlock textBlock, string termToBeHighlighted, string textPart)
        {
            if (termToBeHighlighted.Contains(textPart))
                AddHighlightedPartToTextBlock(textBlock, textPart);
            else
                AddPartToTextBlock(textBlock, textPart);
        }

        private static void AddPartToTextBlock(TextBlock textBlock, string part)
        {
            //此处样式为硬编码，有待优化🤣
            textBlock.Inlines.Add(new Run { Text = part, FontWeight = FontWeights.Bold, Foreground = new SolidColorBrush(Color.FromRgb(0, 0, 0)) });
        }

        private static void AddHighlightedPartToTextBlock(TextBlock textBlock, string part)
        {
            //此处样式为硬编码，有待优化🤣
            textBlock.Inlines.Add(new Run { Text = part, FontWeight = FontWeights.Bold, Foreground = new SolidColorBrush(Color.FromRgb(0xFF, 0, 0)) });
        }


        public static List<string> SplitTextIntoTermAndNotTermParts(string text, string term)
        {
            if (string.IsNullOrEmpty(text))
                return new List<string>() { string.Empty };

            return Regex.Split(text, $@"({term})")
                        .Where(p => p != string.Empty)
                        .ToList();
        }
    }
}
```