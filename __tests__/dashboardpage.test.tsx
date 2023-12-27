import Home from '@/app/page';
import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';

describe('Main Page Component Render', () => {
  it('should render properly', () => {
    render(<Home />);
    const myText: HTMLElement = screen.getByText(/tsx/i);

    expect(myText).toBeInTheDocument();
  });
});
