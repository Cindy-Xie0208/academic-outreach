# Academic Outreach — Private Mentor Review

这是“只有你和申请老师能看见”的版本。

## 架构
- GitHub Pages：只托管前端页面
- Supabase Auth：真正的邮箱/密码登录
- Supabase Database + Row Level Security：套磁信和导师记录不写进 HTML，也不会暴露给未授权访客
- 你的账号：Owner，可编辑
- 申请老师账号：Mentor，只读

## 1. 建 Supabase 项目
访问 https://supabase.com/ 创建免费项目。

## 2. 执行数据库脚本
打开 Supabase → SQL Editor，把 `schema.sql` 全部粘贴并运行。

## 3. 建两个登录账号
Supabase → Authentication → Users：
- 你的邮箱账号
- 申请老师邮箱账号

建议先手动创建账号，不开放公开注册。

## 4. 配置角色
在 Authentication → Users 复制两个用户 UUID。
然后在 SQL Editor 执行：

```sql
insert into public.profiles (id, role, display_name)
values
('你的 UUID','owner','Cindy'),
('老师 UUID','mentor','Application Mentor');

insert into public.mentor_access (owner_id, mentor_id)
values ('你的 UUID','老师 UUID');
```

## 5. 配置前端
Supabase → Project Settings → API，复制：
- Project URL
- anon public key

打开 `config.js`，替换：

```js
window.SUPABASE_URL = "...";
window.SUPABASE_ANON_KEY = "...";
```

anon key 可以出现在前端；真正的权限由 RLS 控制。不要放 service_role key。

## 6. 上传到 GitHub Pages
把以下三个文件放到你的 `academic-outreach` 仓库根目录：
- `index.html`
- `config.js`

`schema.sql` 不需要上传到公开仓库。

GitHub Pages 地址可以继续使用：
`https://cindy-xie0208.github.io/academic-outreach/`

未登录的人只会看到登录页；即使查看网页源代码，也拿不到套磁信正文，因为正文在 Supabase 数据库里。

## 7. 使用方式
你登录：
- 添加目标导师
- 编辑 Research Fit
- 写套磁信
- 修改状态
- 修改个人资料

老师登录：
- 能看到你的导师记录
- 能看到套磁信正文
- 不能编辑

## 安全提醒
- 不要开启匿名注册。
- 不要把 `service_role` 密钥放进网页。
- 老师不再需要访问时，删除 `mentor_access` 对应记录或禁用其 Auth 用户。
