export function LoadingScreen({ message = 'Loading your workspace…' }: { message?: string }) {
  return (
    <div className="loading-screen">
      <div className="loading-spinner" aria-hidden />
      <p>{message}</p>
    </div>
  );
}
