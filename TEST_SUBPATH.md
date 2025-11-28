# Hướng dẫn test Subpath cho Uptime Kuma

## Cách 1: Sử dụng biến môi trường

### Windows PowerShell:
```powershell
$env:UPTIME_KUMA_BASE_PATH="/uptime"
node server/server.js
```

### Windows CMD:
```cmd
set UPTIME_KUMA_BASE_PATH=/uptime
node server/server.js
```

### Linux/Mac:
```bash
export UPTIME_KUMA_BASE_PATH=/uptime
node server/server.js
```

## Cách 2: Sử dụng command line argument

```bash
node server/server.js --base-path=/uptime
```

## Cách 3: Sử dụng Docker (đã được cấu hình sẵn)

```bash
docker run -e UPTIME_KUMA_BASE_PATH=/uptime ...
```

## Kiểm tra

1. Sau khi start server, bạn sẽ thấy log: `Base path: /uptime`
2. Truy cập: `http://localhost:3001/uptime`
3. Vue Router sẽ tự động detect base path từ `<base>` tag
4. Tất cả routes sẽ hoạt động với prefix `/uptime`

## Lưu ý

- Base path phải bắt đầu bằng `/` (ví dụ: `/uptime`, không phải `uptime`)
- Base path không nên kết thúc bằng `/` (sẽ được tự động normalize)
- Setup-database server chạy ở root `/` (không có base path)

