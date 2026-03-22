export const metadata = {
  title: 'LifeSync - Journal App Preview',
  description: 'Interactive mobile preview of the LifeSync journal app',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="de">
      <body style={{margin: 0, padding: 0}}>{children}</body>
    </html>
  )
}
